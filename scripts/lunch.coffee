# Description:
#   get lunch menus on this weeks of dh-cafeteria.com
#
# Commands:
#   hubot lunch - Get lunch menus on today
#   hubot lunch <day> - Get lunch menus for day of week
#
# Author:
#   takuya sugimoto

cheerio = require 'cheerio'

module.exports = (robot) ->
  robot.respond /lunch(?:| (sun|mon|tue|wed|thu|fri|sat))$/i, (msg) ->
    lunch = new Lunch()
    lunch.check(msg, msg.match[1])

class Lunch
  _url = 'http://www.dh-cafeteria.com/lunch.html'

  _messages = {
    holiday: 'カフェテリアはおやすみですm(_ _)m'
    error: 'カフェテリアのメニュー取得に失敗しました(-_-;)'
  }

  _checkDay = (day) ->
    if day
      switch day.toLowerCase()
        when 'sun' then return 0
        when 'mon' then return 1
        when 'tue' then return 2
        when 'wed' then return 3
        when 'thu' then return 4
        when 'fri' then return 5
        when 'sat' then return 6
    date = new Date
    return date.getDay()

  check: (msg, day) ->
    day = _checkDay(day)
    if day == 0 || day == 6
      msg.send _messages.holiday
    else
      msg.http(_url).get() (error, response, body) =>
        if error || response.statusCode != 200
          return msg.send _messages.error
        $ = cheerio.load(body)
        colum = $('#main td')
        menus = {}
        menus[colum.eq(0).text()]   = colum.eq(day).text()       # ランチA
        menus[colum.eq(18).text()]  = colum.eq(day + 18).text()  # ランチB
        menus[colum.eq(36).text()]  = colum.eq(day + 41).text()  # ランチC
        menus[colum.eq(52).text()]  = colum.eq(day + 52).text()  # どんぶり
        menus[colum.eq(63).text()]  = colum.eq(day + 63).text()  # カレー
        menus[colum.eq(75).text()]  = colum.eq(day + 75).text()  # ラーメン
        menus[colum.eq(86).text()]  = colum.eq(day + 86).text()  # うどん/そば
        menus[colum.eq(104).text()] = colum.eq(day + 104).text() # テイクアウト甩弁当A
        menus[colum.eq(110).text()] = colum.eq(day + 110).text() # テイクアウト甩弁当B
        msg.send "#{key.replace(/(?:\\|￥).*?$/, '')} / #{value}" for key, value of menus
        return
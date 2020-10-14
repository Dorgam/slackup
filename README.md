NOTE: This repo is currently obsolete due to changes in the APIs

# Slackup - Slack backup utility

## Introduction

Slackup is tool that does regular backup (Each 10 minutes, daily, or weekly) to your Slack account (at a team you select) then it union the new data with the stored data (.json files) in your Dropbox account. Finally, it generate HTML files and backs them up again (along with union jsons) to your dropbox account.

## Installation

To install Slackup, simply click on this Heroku button:

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

Once the application is installed on your Heroku account, use the setup guide to backup your application

## Setup Guide

To schedule backup for a slack account you need to collect three infos:

* Slack username (Getting this is pretty obvious, just find your username in chat)
* Slack Authentication Token
* Dropbox Authentication Token

### Slack Authentication Token:

* Go to Slack [Web Api](https://api.slack.com/web)
* Scroll down and click on “Generate test tokens” Button
* Click on “Create token” button that is parallel to team you want to backup its conversations
* Copy the new appearing token and store it somewhere safe

### Dropbox Authentication Token:

* Go to Dropbox [App Console](https://www.dropbox.com/developers/apps).
* Click on Create App
* Choose the follwoing settings:
  * API: Dropbox API
  * Type of Access: App Folder
  * Name your app: Anything unique you like
  * After you enter the settings, click on “Create App”
  * In the next page, scroll down until you find “Generate” button
  * . Copy the generated token and keep it somewhere safe

## Adding Your Slack Account to Heroku Scheduler:

* Login to [Heroku](https://dashboard.heroku.com/apps)
* Select Slackup application
* In app overview pages click on Heroku Scheduler
* A new page will appear, in that page click “Add new job”
* In the appearing field write the following: `ruby app.rb 'YOUR_SLACK_TOKEN' 'YOUR_USERNAME' 'YOUR_DROPBOX_TOKEN'`
* Change the other options as you wish.
* Click "Save" and enjoy.

## Licence

MIT License

Copyright (c) 2016 Osama Alsalman

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

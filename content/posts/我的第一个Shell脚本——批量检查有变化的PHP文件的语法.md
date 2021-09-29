---
title: 我的第一个Shell脚本——批量检查有变化的PHP文件的语法
date: 2018-03-20T10:19:40+08:00
lastmod: 2021-09-29T10:19:40+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: /img/cover.jpg
# images:
#   - /img/cover.jpg
categories:
  - 技术文章
tags:
  - shell
# nolastmod: true
draft: false
---

php -l 检查php文件的语法正确性，但是php -l 总是要一个一个文件的检查，感觉好麻烦，正好还没写过shell脚本，于是借着这个机会学习一下。

<!--more-->

 #!/bin/bash
    PHP_VERSION=`php -v |awk '{print $1,$2}'|head -1`
    echo -e "当前系统PHP版本：${PHP_VERSION} \n"
    err_flag=0
    for file in `git status`
    do
        result=$(echo $file | grep "php")
        if [[ "$result" != "" ]]
        then
            error=$(php -l $result)
            hasErr=$(echo $error | grep "Parse error")
            if [[ $hasErr != "" ]]
            then
                err_flag=1
            fi
        fi
    done

    echo -e "\n"
    if [[ $err_flag == 1 ]]
    then
        echo '请修复以上PHP文件语法错误'
    else
        echo '所有变更的PHP文件语法均正确'
    fi


### 拓展内容
- 字符串包含字符串判断：https://www.cnblogs.com/AndyStudy/p/6064834.html
- 如何取多行中的第一行：https://zhidao.baidu.com/question/1801341523241054747.html

改进版：

    #!/bin/bash
    PHP_VERSION=`php -v |awk '{print $1,$2}'|head -1`
    echo -e "当前系统PHP版本：${PHP_VERSION} \n"
    err_flag=0
    for file in `git status`
    do
        result=$(echo $file | grep "php")
        if [[ "$result" != "" ]]
        then
            error=$(php -l $result)
            hasErr=$(echo $error | grep "Parse error")
            if [[ $hasErr != "" ]]
            then
                err_flag=1
            fi
        fi
    done

    echo -e "\n"
    if [[ $err_flag == 1 ]]
    then
        echo '请修复以上PHP文件语法错误'
    else
        echo '所有变更的PHP文件语法均正确'
        echo -e "\n"
        echo 'formating...'
        for file in `git status`
        do
            result=$(echo $file |grep "php")
            if [[ "$result" != "" ]]
            then
                php-cs-fixer fix $result
            fi
        done
        echo 'formatted...'
    fi

<!--declare-declare-->

Copyright &copy; 2017 - 2018 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】

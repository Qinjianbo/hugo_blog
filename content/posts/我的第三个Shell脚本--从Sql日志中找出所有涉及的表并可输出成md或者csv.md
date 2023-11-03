---
title: 我的第三个Shell脚本  从Sql日志中找出所有涉及的表并可输出成md或者csv
date: 2018-04-13T10:22:28+08:00
lastmod: 2021-09-29T10:22:28+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: https://blog-boboidea.oss-cn-hangzhou.aliyuncs.com/article/img/posts/我的第三个Shell脚本 从Sql日志中找出所有涉及的表并可输出成md或者csv.jpg
# images:
#   - /img/cover.jpg
categories:
  - 技术文章
tags:
  - shell
# nolastmod: true
draft: false
---

这是一个Shell脚本记录，该脚本通过使用linux下的命令：cat，grep，sed，awk，sort，uniq来对Sql日志进行分析，并自动生成可执行php文件，将结果以csv或md的形式进行输出。

<!--more-->

> 这是一个Shell脚本记录，该脚本通过使用linux下的命令：cat，grep，sed，awk，sort，uniq来对Sql日志进行分析，并自动生成可执行php文件，将结果以csv或md的形式进行输出。

```
#!/bin/bash
if [[ $1 == '' ]];then
    echo "请输入要分析的文件路径及名称"
    exit 1
fi
if [[ $2 == '' ]];then
    echo "请输入最终要生成的文件类型，可输入 md 或者 csv"
    exit 1
fi
md="md"
csv="csv"
if [[ $2 != md && $2 != csv ]];then
    echo "目前生成文件类型仅支持md 和 csv"
    exit
fi
if [[ ! -f $1 ]];then
    echo "文件不存在"
    exit 1
else
    echo "要分析的文件: $1"
fi
echo '开始分析...'
result=$(cat $1 |\
    grep "module" |\
    awk -F: '{print $4, $5, $6, $7}'|\
    sed 's/module /["module" => "/g' |\
    sed 's/ act /", "act" => "/g' |\
    sed 's/ sql /", "table" => "/g' |\
    sed 's/ cost/"],/g' |\
    sort |\
    uniq |\
    sed 's/select.*from `//ig' |\
    sed 's/INSERT INTO `//ig' |\
    sed 's/INSERT INTO //ig' |\
    sed 's/INSERT IGNORE INTO `//ig' |\
    sed 's/INSERT IGNORE INTO //ig' |\
    sed 's/update `//ig' |\
    sed 's/update //ig' |\
    sed 's/delete from `//ig' |\
    sed 's/delete from //ig' |\
    sed 's/                SELECT sum(a.pnumber) AS allnum, a.productid,a.sgmsid                FROM //ig' |\
    sed 's/SELECT.*FROM //ig' |\
    sed 's/ product                    LEFT JOIN /|/ig' |\
    sed 's/ c                LEFT JOIN /|/ig' |\
    sed 's/ g left join /|/ig' |\
    sed 's/ a left join /|/ig' |\
    sed 's/` inner join `/|/ig' |\
    sed 's/` left join `/|/ig' |\
    sed 's/ a                /,/ig' |\
    sed 's/ aa left join /,/ig' |\
    sed 's/WHERE.*"],/"],/ig' |\
    sed 's/ set .*"],/"],/ig' |\
    sed 's/ product_category ON product.id = product_category.productid//ig' |\
    sed 's/                                        //ig' |\
    sed 's/ b on a.prid=b.prid //ig' |\
    sed 's/ bb on //ig' |\
    sed 's/                //ig' |\
    sed 's/ b            //ig' |\
    sed 's/            //ig' |\
    sed 's/` (`orderid`, .*/"],/ig' |\
    sed 's/` (`ordercode.*/"],/ig' |\
    sed 's/` (`useremail.*/"],/ig' |\
    sed 's/` (`uid.*/"],/ig' |\
    sed 's/` (`oldstatus.*/"],/ig' |\
    sed 's/ i ON c.productid = i.id                //ig' |\
    sed 's/ i ON c.productid = i.id//ig' |\
    sed 's/` set .*/"],/ig' |\
    sed 's/ force index (idx_prefix_useuid_valid) //ig' |\
    sed 's/ force index (prefix_uid_valid) //ig' |\
    sed 's/ i on g.activeid=i.id //ig' |\
    sed 's/`.*"],/"],/ig' |\
    sort|\
    uniq
)
echo '分析结束'
echo -e "<?php\
\n \
\$result=[\n${result}\n];\n \
\$outType='$2'; \n \
\$results = []; \n \
foreach (\$result as \$value) { \n \
    \$results[\$value['module']][] = \$value; \n \
} \n \
foreach (\$results as \$key => \$value) { \n \
    \$arr = []; \n \
    foreach (\$value as \$v) { \n \
        \$arr[\$v['act']][] = \$v; \n \
    } \n \
    \$results[\$key] = \$arr; \n \
} \n \
\$file = 'result.'.\$outType; \n \
if (file_exists(\$file)) { \n \
    unlink(\$file); \n \
} \n \
if (\$outType == 'md') { \n \
    foreach (\$results as \$module => \$acts) { \n \
        file_put_contents(\$file, sprintf(\"### %s\\n\\n\", \$module), FILE_APPEND); \n \
        foreach (\$acts as \$act => \$tables) { \n \
            file_put_contents(\$file, sprintf(\"- %s\\n\\n\", \$act), FILE_APPEND); \n \
            foreach (\$tables as \$table) { \n \
                file_put_contents(\$file, sprintf(\"  - %s\\n\\n\", \$table['table']), FILE_APPEND); \n \
            } \n \
        } \n \
    } \n \
    echo '写入'.\$file.'完成'; \n \
    echo PHP_EOL; \n \
} else if (\$outType == 'csv') { \n \
file_put_contents(\$file, sprintf('%s,%s,%s\\n', iconv('utf-8', 'gb2312', '模块名'), iconv('utf-8', 'gb2312', '接口名'), iconv('utf-8', 'gb2312', '表名'))); \n \
    foreach (\$result as \$value) { \n \
        file_put_contents(\$file, sprintf('%s,%s,%s\\n', \$value['module'], \$value['act'], \$value['table']), FILE_APPEND); \n \
    } \n \
    echo '写入'.\$file.'完成'; \n \
    echo PHP_EOL; \n \
} else { \n \
    echo \$outType.'输出文件类型错误'; \n \
    echo PHP_EOL; \n \
} \n \
" > result.php
echo '结果已经写入result.php'
echo "即将执行result.php"
php result.php
echo "result.php执行完成"
```

> 日志内容格式大概如下：

```
[2018-04-12 13:36:28] lumen.INFO: module:Goods act:getShoppingMallGoodsDetail sql:select SUM(lock_stock) AS num, productid, sgmsid from `shop_goods_lockstock` where `productid` in ('19592') and `storagenum` in ('5', '6', '8', '13', '14', '15', '17', '20', '22', '39', '40', '45') group by `productid`, `sgmsid` cost:0ms
[2018-04-12 13:36:28] lumen.INFO: module:Goods act:getShoppingMallGoodsDetail sql:select * from `shop_global_stock_dist` where `productid` in ('19592') and `valid` = '1' cost:0ms
[2018-04-12 13:36:28] lumen.INFO: module:Goods act:getShoppingMallGoodsDetail sql:select `gxcast`, `newcast`, `cast`, `valid` from `shop_goods_info` where `shop_goods_info`.`id` = '19592' limit 1 cost:0ms
[2018-04-12 13:36:28] lumen.INFO: req(url:http://openapi-search.boqii.com/v3.7/shop/product/brand/count,cost:0.012s)
[2018-04-12 13:36:28] lumen.INFO: module:Goods act:getShoppingMallGoodsDetail sql:select `config_id`, `config_key`, `config_value`, `config_status` from `shop_configs` where `config_key` = 'is_globalorder_dutyfree' and `config_status` = '1' limit 1 cost:0ms
[2018-04-12 13:36:28] lumen.INFO: module:Goods act:getShoppingMallGoodsDetail sql:select distinct activeid as activeid from `shop_activity_goods` where `productid` in ('19592') and `type` = '1' cost:0ms
[2018-04-12 13:36:28] lumen.INFO: module:Goods act:getShoppingMallGoodsDetail sql:select `id`, `name`, `subtitle`, `starttime`, `endtime`, `status`, `isfare`, `type`, `discountprice`, `discount`, `parttype`, `grade`, `presentminbuy`, `isstopbuy`, `minbuy`, `mostbuy`, `stopbuynum`, `activetitle`, `activeurl`, `sale_city`, `isflashsale`, `ispublicuse`, `bean`, `isappuse`, `limittime`, `meetcondition`, `meetconditionx`, `createtime`, `updatetime`, `will_sell_stock`, `if_will_sell`, `isglobal`, `seckill_goods_type_num`, `is_show_notice`, `is_app_show`, `ispublicbean`, `tag_name`, `is_card`, `price_type` from `shop_activity_info` where `status` = '1' and `endtime` >= '1523511388' and (`parttype` = '1' or `id` in ('7264', '7708', '6483', '6894', '7266', '8458', '8782', '9408', '9787', '9904', '10450', '10451', '10452', '11006', '11142', '11450', '11855', '11866')) cost:1ms
[2018-04-12 13:36:28] lumen.INFO: module:Goods act:getShoppingMallGoodsDetail sql:select `id`, `subtitle`, `starttime`, `endtime`, `productids`, `third_cateids`, `brandids`, `parttype`, `send_days`, `send_times`, `tag_name`, `couponinfo`, `type`, `status` from `shop_activity_coupon_info` where `type` = '24' and `starttime` <= '1523511388' and `endtime` >= '1523511388' and `status` = '1' and `valid` = '1' cost:0ms
[2018-04-12 13:36:28] lumen.INFO: module:Goods act:getShoppingMallGoodsDetail sql:select `id`, `productid`, `activeid`, `isattr`, `attrid`, `discountprice`, `discount`, `presentnum`, `type`, `packageid`, `packagename`, `meetmoney`, `bartermoney`, `will_sell_stock`, `cate1`, `sort`, `v34_price`, `v5_price`, `is_v34_price`, `is_v5_price`, `price_time_limit` from `shop_activity_goods` where `activeid` in ('11855', '11866') cost:16ms
[2018-04-12 13:36:28] lumen.INFO: module:Goods act:getShoppingMallGoodsDetail sql:select `uid`, `grade`, `balance`, `balance_type` from `boqii_users` where `uid` in ('18130683') cost:0ms
[2018-04-12 13:36:28] lumen.INFO: module:Goods act:getShoppingMallGoodsDetail sql:select `uid`, `type`, `status`, `is_black_card` from `boqii_users_magical_card` where `uid` in ('18130683') cost:0ms
[2018-04-12 13:36:28] lumen.INFO: module:Goods act:getShoppingMallGoodsDetail sql:select `discount_rate` from `boqii_magical_card_interests_info` where `card_type` = '2' and `interests_type` = '6' and `valid` = '1' limit 1 cost:0ms
[2018-04-12 13:36:28] lumen.INFO: module:Goods act:getShoppingMallGoodsDetail sql:select `discount_rate` from `boqii_magical_card_interests_info` where `card_type` = '3' and `interests_type` = '6' and `valid` = '1' limit 1 cost:0ms
[2018-04-12 13:36:28] lumen.INFO: module:Goods act:getShoppingMallGoodsDetail sql:select `discount_rate` from `boqii_magical_card_interests_info` where `card_type` = '2' and `interests_type` = '6' and `valid` = '1' limit 1 cost:0ms
[2018-04-12 13:36:28] lumen.INFO: module:Goods act:getShoppingMallGoodsDetail sql:select `discount_rate` from `boqii_magical_card_interests_info` where `card_type` = '3' and `interests_type` = '6' and `valid` = '1' limit 1 cost:0ms
[2018-04-12 13:36:28] lumen.INFO: module:Goods act:getShoppingMallGoodsDetail sql:select `discount_rate` from `boqii_magical_card_interests_info` where `card_type` = '2' and `interests_type` = '6' and `valid` = '1' limit 1 cost:0ms
[2018-04-12 13:36:28] lumen.INFO: module:Goods act:getShoppingMallGoodsDetail sql:select `discount_rate` from `boqii_magical_card_interests_info` where `card_type` = '3' and `interests_type` = '6' and `valid` = '1' limit 1 cost:0ms
[2018-04-12 13:36:28] lumen.INFO: module:Goods act:getShoppingMallGoodsDetail sql:select `discount_rate` from `boqii_magical_card_interests_info` where `card_type` = '2' and `interests_type` = '6' and `valid` = '1' limit 1 cost:0ms
[2018-04-12 13:36:28] lumen.INFO: module:Goods act:getShoppingMallGoodsDetail sql:select `discount_rate` from `boqii_magical_card_interests_info` where `card_type` = '3' and `interests_type` = '6' and `valid` = '1' limit 1 cost:0ms
[2018-04-12 13:36:28] lumen.INFO: module:Goods act:getShoppingMallGoodsDetail sql:select `discount_rate` from `boqii_magical_card_interests_info` where `card_type` = '2' and `interests_type` = '6' and `valid` = '1' limit 1 cost:0ms
[2018-04-12 13:36:28] lumen.INFO: module:Goods act:getShoppingMallGoodsDetail sql:select `discount_rate` from `boqii_magical_card_interests_info` where `card_type` = '3' and `interests_type` = '6' and `valid` = '1' limit 1 cost:0ms
[2018-04-12 13:36:28] lumen.INFO: module:Goods act:getShoppingMallGoodsDetail sql:select `id`, `subtitle`, `starttime`, `endtime`, `productids`, `third_cateids`, `brandids`, `ordertype`, `parttype`, `send_days`, `couponinfo`, `is_card` from `shop_activity_coupon_info` where `type` = '14' and `starttime` <= '1523511388' and `endtime` >= '1523511388' and `status` = '1' and `valid` = '1' cost:0ms
[2018-04-12 13:36:28] lumen.INFO: module:Goods act:getShoppingMallGoodsDetail sql:select `discount_rate` from `boqii_magical_card_interests_info` where `card_type` = '2' and `interests_type` = '6' and `valid` = '1' limit 1 cost:0ms
[2018-04-12 13:36:28] lumen.INFO: module:Goods act:getShoppingMallGoodsDetail sql:select `discount_rate` from `boqii_magical_card_interests_info` where `card_type` = '3' and `interests_type` = '6' and `valid` = '1' limit 1 cost:0ms
[2018-04-12 13:36:28] lumen.INFO: module:Goods act:getShoppingMallGoodsDetail sql:select `discount_rate` from `boqii_magical_card_interests_info` where `card_type` = '2' and `interests_type` = '6' and `valid` = '1' limit 1 cost:0ms
[2018-04-12 13:36:28] lumen.INFO: module:Goods act:getShoppingMallGoodsDetail sql:select `discount_rate` from `boqii_magical_card_interests_info` where `card_type` = '3' and `interests_type` = '6' and `valid` = '1' limit 1 cost:0ms
[2018-04-12 13:36:28] lumen.INFO: module:Goods act:getShoppingMallGoodsDetail sql:select `discount_rate` from `boqii_magical_card_interests_info` where `card_type` = '2' and `interests_type` = '6' and `valid` = '1' limit 1 cost:0ms
[2018-04-12 13:36:28] lumen.INFO: module:Goods act:getShoppingMallGoodsDetail sql:select `discount_rate` from `boqii_magical_card_interests_info` where `card_type` = '3' and `interests_type` = '6' and `valid` = '1' limit 1 cost:0ms
[2018-04-12 13:36:28] lumen.INFO: module:Goods act:getShoppingMallGoodsDetail sql:select `discount_rate` from `boqii_magical_card_interests_info` where `card_type` = '2' and `interests_type` = '6' and `valid` = '1' limit 1 cost:0ms
[2018-04-12 13:36:28] lumen.INFO: module:Goods act:getShoppingMallGoodsDetail sql:select `discount_rate` from `boqii_magical_card_interests_info` where `card_type` = '3' and `interests_type` = '6' and `valid` = '1' limit 1 cost:0ms
[2018-04-12 13:36:28] lumen.INFO: module:Goods act:getShoppingMallGoodsDetail sql:select `discount_rate` from `boqii_magical_card_interests_info` where `card_type` = '2' and `interests_type` = '6' and `valid` = '1' limit 1 cost:0ms
[2018-04-12 13:36:28] lumen.INFO: module:Goods act:getShoppingMallGoodsDetail sql:select `discount_rate` from `boqii_magical_card_interests_info` where `card_type` = '3' and `interests_type` = '6' and `valid` = '1' limit 1 cost:0ms
[2018-04-12 13:36:28] lumen.INFO: module:Goods act:getShoppingMallGoodsDetail sql:select `discount_rate` from `boqii_magical_card_interests_info` where `card_type` = '2' and `interests_type` = '6' and `valid` = '1' limit 1 cost:0ms
[2018-04-12 13:36:28] lumen.INFO: module:Goods act:getShoppingMallGoodsDetail sql:select `discount_rate` from `boqii_magical_card_interests_info` where `card_type` = '3' and `interests_type` = '6' and `valid` = '1' limit 1 cost:0ms
[2018-04-12 13:36:28] lumen.INFO: module:Goods act:getShoppingMallGoodsDetail sql:select `discount_rate` from `boqii_magical_card_interests_info` where `card_type` = '2' and `interests_type` = '6' and `valid` = '1' limit 1 cost:0ms
[2018-04-12 13:36:28] lumen.INFO: module:Goods act:getShoppingMallGoodsDetail sql:select `discount_rate` from `boqii_magical_card_interests_info` where `card_type` = '3' and `interests_type` = '6' and `valid` = '1' limit 1 cost:0ms
```

<!--declare-declare-->

Copyright &copy; 2017 - 2023 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】

---
title: cluster_block_exception 
date: 2018-04-03T10:15:53+08:00
lastmod: 2021-09-29T10:15:53+08:00
author: 胡巴
avatar: /img/avatar.jpeg
# authorlink: https://author.site
cover: /img/cover.jpg
# images:
#   - /img/cover.jpg
categories:
  - 问题积累
tags:
  - elasticsearch
# nolastmod: true
draft: false
---

事件：早上在看自己的文章列表时发现昨晚写的一篇新的博客没有列出来，但是文章的排序仍然正确。  原因分析：  因为自己的读取策略是先读取ES，排序由ES进行！~若ES执行结果出错，则从数据库读取列表，排序默认。

<!--more-->

 # cluster_block_exception

> 事件：早上在看自己的文章列表时发现昨晚写的一篇新的博客没有列出来，但是文章的排序仍然正确。

### 原因分析

> 因为自己的读取策略是先读取ES，排序由ES进行！~若ES执行结果出错，则从数据库读取列表，排序默认。

> 而当前的状况是列表排序是按照ES 的排序进行的，但是新文章没有列出来。

#### 结论

> ES更新索引失败！

### 验证

> 进入自己的ES项目，查看索引更新日志。果然，报错了，索引更新失败。

> 报错信息：

```
    [2018-04-03 01:19:07] product.ERROR: {"error":{"root_cause":[{"type":"cluster_block_exception","reason":"blocked by: [FORBIDDEN/12/index read-only / allow delete (api)];"}],"type":"cluster_block_exception","reason":"blocked by: [FORBIDDEN/12/index read-only / allow delete (api)];"},"status":403} {"exception":"[object] (Elasticsearch\\Common\\Exceptions\\Forbidden403Exception(code: 403): {\"error\":{\"root_cause\":[{\"type\":\"cluster_block_exception\",\"reason\":\"blocked by: [FORBIDDEN/12/index read-only / allow delete (api)];\"}],\"type\":\"cluster_block_exception\",\"reason\":\"blocked by: [FORBIDDEN/12/index read-only / allow delete (api)];\"},\"status\":403} at /var/www/html/search/vendor/elasticsearch/elasticsearch/src/Elasticsearch/Connections/Connection.php:600)
    [stacktrace]
    #0 /var/www/html/search/vendor/elasticsearch/elasticsearch/src/Elasticsearch/Connections/Connection.php(273): Elasticsearch\\Connections\\Connection->process4xxError(Array, Array, Array)
    #1 /var/www/html/search/vendor/react/promise/src/FulfilledPromise.php(25): Elasticsearch\\Connections\\Connection->Elasticsearch\\Connections\\{closure}(Array)
    #2 /var/www/html/search/vendor/guzzlehttp/ringphp/src/Future/CompletedFutureValue.php(55): React\\Promise\\FulfilledPromise->then(Object(Closure), NULL, NULL)
    #3 /var/www/html/search/vendor/guzzlehttp/ringphp/src/Core.php(341): GuzzleHttp\\Ring\\Future\\CompletedFutureValue->then(Object(Closure), NULL, NULL)
    #4 /var/www/html/search/vendor/elasticsearch/elasticsearch/src/Elasticsearch/Connections/Connection.php(294): GuzzleHttp\\Ring\\Core::proxy(Object(GuzzleHttp\\Ring\\Future\\CompletedFutureArray), Object(Closure))
    #5 /var/www/html/search/vendor/elasticsearch/elasticsearch/src/Elasticsearch/Connections/Connection.php(171): Elasticsearch\\Connections\\Connection->Elasticsearch\\Connections\\{closure}(Array, Object(Elasticsearch\\Connections\\Connection), Object(Elasticsearch\\Transport), Array)
    #6 /var/www/html/search/vendor/elasticsearch/elasticsearch/src/Elasticsearch/Transport.php(106): Elasticsearch\\Connections\\Connection->performRequest('POST', '/_aliases', Array, '{\"actions\":[{\"r...', Array, Object(Elasticsearch\\Transport))
    #7 /var/www/html/search/vendor/elasticsearch/elasticsearch/src/Elasticsearch/Namespaces/AbstractNamespace.php(72): Elasticsearch\\Transport->performRequest('POST', '/_aliases', Array, Array, Array)
    #8 /var/www/html/search/vendor/elasticsearch/elasticsearch/src/Elasticsearch/Namespaces/IndicesNamespace.php(897): Elasticsearch\\Namespaces\\AbstractNamespace->performRequest(Object(Elasticsearch\\Endpoints\\Indices\\Aliases\\Update))
    #9 /var/www/html/search/app/Models/Blog/Blog.php(83): Elasticsearch\\Namespaces\\IndicesNamespace->updateAliases(Array)
    #10 /var/www/html/search/app/Console/Commands/BulkCommand.php(41): App\\Models\\Blog\\Blog->bulkIndex()
    #11 [internal function]: App\\Console\\Commands\\BulkCommand->handle()
    #12 /var/www/html/search/vendor/laravel/framework/src/Illuminate/Container/BoundMethod.php(29): call_user_func_array(Array, Array)
    #13 /var/www/html/search/vendor/laravel/framework/src/Illuminate/Container/BoundMethod.php(87): Illuminate\\Container\\BoundMethod::Illuminate\\Container\\{closure}()
    #14 /var/www/html/search/vendor/laravel/framework/src/Illuminate/Container/BoundMethod.php(31): Illuminate\\Container\\BoundMethod::callBoundMethod(Object(Illuminate\\Foundation\\Application), Array, Object(Closure))
    #15 /var/www/html/search/vendor/laravel/framework/src/Illuminate/Container/Container.php(549): Illuminate\\Container\\BoundMethod::call(Object(Illuminate\\Foundation\\Application), Array, Array, NULL)
    #16 /var/www/html/search/vendor/laravel/framework/src/Illuminate/Console/Command.php(183): Illuminate\\Container\\Container->call(Array)
    #17 /var/www/html/search/vendor/symfony/console/Command/Command.php(252): Illuminate\\Console\\Command->execute(Object(Symfony\\Component\\Console\\Input\\ArgvInput), Object(Illuminate\\Console\\OutputStyle))
    #18 /var/www/html/search/vendor/laravel/framework/src/Illuminate/Console/Command.php(170): Symfony\\Component\\Console\\Command\\Command->run(Object(Symfony\\Component\\Console\\Input\\ArgvInput), Object(Illuminate\\Console\\OutputStyle))
    #19 /var/www/html/search/vendor/symfony/console/Application.php(936): Illuminate\\Console\\Command->run(Object(Symfony\\Component\\Console\\Input\\ArgvInput), Object(Symfony\\Component\\Console\\Output\\ConsoleOutput))
    #20 /var/www/html/search/vendor/symfony/console/Application.php(240): Symfony\\Component\\Console\\Application->doRunCommand(Object(App\\Console\\Commands\\BulkCommand), Object(Symfony\\Component\\Console\\Input\\ArgvInput), Object(Symfony\\Component\\Console\\Output\\ConsoleOutput))
    #21 /var/www/html/search/vendor/symfony/console/Application.php(148): Symfony\\Component\\Console\\Application->doRun(Object(Symfony\\Component\\Console\\Input\\ArgvInput), Object(Symfony\\Component\\Console\\Output\\ConsoleOutput))
    #22 /var/www/html/search/vendor/laravel/framework/src/Illuminate/Console/Application.php(88): Symfony\\Component\\Console\\Application->run(Object(Symfony\\Component\\Console\\Input\\ArgvInput), Object(Symfony\\Component\\Console\\Output\\ConsoleOutput))
    #23 /var/www/html/search/vendor/laravel/framework/src/Illuminate/Foundation/Console/Kernel.php(121): Illuminate\\Console\\Application->run(Object(Symfony\\Component\\Console\\Input\\ArgvInput), Object(Symfony\\Component\\Console\\Output\\ConsoleOutput))
    #24 /var/www/html/search/artisan(37): Illuminate\\Foundation\\Console\\Kernel->handle(Object(Symfony\\Component\\Console\\Input\\ArgvInput), Object(Symfony\\Component\\Console\\Output\\ConsoleOutput))
    #25 {main}
    "}
```

> 主要原因是这个：

```
    {"error":{"root_cause":[{"type":"cluster_block_exception","reason":"blocked by: [FORBIDDEN/12/index read-only / allow delete (api)];"}],"type":"cluster_block_exception","reason":"blocked by: [FORBIDDEN/12/index read-only / allow delete (api)];"},"status":403}
```

> 通过在网络中查询，得出大概原因是ES新节点的数据目录data存储空间不足，导致从master主节点接收同步数据的时候失败，此时ES集群为了保护数据，会自动把索引分片index置为只读read-only。看到这里我想到确实是昨天自己服务器磁盘被写满了，应该是那时索引没有了存储空间导致的。

> 我们看下现在的索引设置：

```
    curl -XGET localhost:9200/_settings?pretty

    {
      "blog_v1_product" : {
        "settings" : {
          "index" : {
            "number_of_shards" : "2",
            "blocks" : {
              "read_only_allow_delete" : "true"
            },
            "provided_name" : "blog_v1_product",
            "creation_date" : "1522544402424",
            "analysis" : {
              "analyzer" : {
                "ik_smart" : {
                  "tokenizer" : "ik_smart"
                },
                "ik_max_word" : {
                  "tokenizer" : "ik_max_word"
                }
              }
            },
            "number_of_replicas" : "2",
            "uuid" : "0uatJENnQ8OujQH2okT4sQ",
            "version" : {
              "created" : "6020299"
            }
          }
        }
      },
      "blog_v0_product" : {
        "settings" : {
          "index" : {
            "number_of_shards" : "2",
            "provided_name" : "blog_v0_product",
            "creation_date" : "1522718347311",
            "analysis" : {
              "analyzer" : {
                "ik_smart" : {
                  "tokenizer" : "ik_smart"
                },
                "ik_max_word" : {
                  "tokenizer" : "ik_max_word"
                }
              }
            },
            "number_of_replicas" : "2",
            "uuid" : "o-QpU1KHTm-ntK_HZqBPaA",
            "version" : {
              "created" : "6020299"
            }
          }
        }
      }
    }
```

> 可以看到里面有个索引 blog_v1_product 有一个

```
    "blocks" : {
      "read_only_allow_delete" : "true"
    },
```

> 正是这个`read_only_allow_delete`导致的！！！

### 解决方法

> 1. 要给data数据足够的存储空间，可以更改data数据的存储路径，如果改这个，要记得从起ES。如果释放完你磁盘的空间，数据的存储空间还是够的就不用改存储路径了。
> 2. 然后要做的就是把索引的设置`read_only_allow_delete` 变成false。

```
     curl -XPUT localhost:9200/blog_v1_product/_settings?pretty -H "content-type:application/json" -d '{ "index": {    "blocks": {"read_only_allow_delete":"false"} } }'

        {
           "acknowledged" : true
        }
```

> 经过上面的处理后，索引就能再次正常更新了。

<!--declare-declare-->

Copyright &copy; 2017 - 2018 boboidea.com All Rights Reserved 波波创意软件工作室 版权所有 【转载请注明出处】

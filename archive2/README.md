# archive2

从Gitlab中自动导出仓库archive文件

## 使用

1. 浏览Gitlab，查看最近提交过更新的仓库

2. 查看仓库的ID，仓库名称

3. 修改archive2.sh代码：

```bash
PROJECTS=(
    "492,Antares"
    "716,Dianbo2PlayerJoiner"
    "511,xStreamPlayer"
    "510,UserPlayerJoiner" 
    "500,Monitor_RelationService"
    "525,WSCascade"
    "522,WSV3"
)
```

4. 运行

```bash
    $ ./archive2 -t <TOKEN>
```

5. 自动下载的存档文件默认保存在.tmp/目录下
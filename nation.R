
# 生成23个以省份命名的文件夹
# 每个省文件夹里里面有一个“XX省_index.txt“文件
# for循环，调用文件”one_pvc.R“中的SetPvc()函数

rm(list = ls())

require(rvest)
require(stringr)
require(data.table)

start_url <- "http://www.tjcn.org/tjgb/"

pvc_node <- read_html(start_url) %>%
  html_nodes("p+ p a")

pvc_list <- html_text(pvc_node)
pvc_link <- html_attr(pvc_node, "href")

pvc_df <- data.frame(name = pvc_list, link = pvc_link, stringsAsFactors = FALSE)

dt <- as.data.table(pvc_df, str)
setkey(dt, "name")
mcity_dt <- dt[c("北京", "上海", "重庆", "天津")] # 直辖市
pvc_dt <- dt[!c("北京", "上海", "重庆", "天津", "中国")] 

pvc_dt 

# -------------------------------------------------

source("one_pvc.R")
for (i in 1:nrow(pvc_dt)) {
 PvcName <- pvc_dt[i, name]
 PvcLink <- paste0("http://www.tjcn.org", pvc_dt[i, link])
 
 tryCatch(
   {
     SetPvc(name = PvcName, pvc_url = PvcLink)
     message(PvcName, "初始化完成啦啦啦~~~")
    },
   error = function(e) {
     message(PvcName, "初始化出错", "!!!!!!!!!!!!!!!!!!!")
   }
 )

}
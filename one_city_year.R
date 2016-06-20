  
# 单个城市单个年度的统计报告
# 输入XX城市XX年度的统计报告网页地址
# 输出一个txt/word文件
  

require(rvest)
require(stringr)


ScpCY <- function(city_start_url) {
  # 解析网页源代码
  message("开始请求网站。。。可能要等好久呢(╯‵□′)╯︵┻━┻")
  htmlcode <- read_html(city_start_url, encoding = "GB18030")
  message("响应成功啦啦啦~~~")
  
  # 提取标题信息，用于校对。
  title <- htmlcode %>% 
    html_node("h2") %>%
    html_text()
  message("开始爬取：", title)
  
  city <- str_replace(title, pattern = "^(.+)(\\d{4})年国民经济和社会发展统计公报", replacement = "\\1")
  year <- str_replace(title, pattern = "^(.+)(\\d{4})年国民经济和社会发展统计公报", replacement = "\\2")
  
  
  # 看看一共有几页
  pagenum <- htmlcode %>%
    html_node(".pagelist") %>%
    html_text() %>%
    str_extract("共\\d{1,2}页") %>% 
    str_extract("\\d{1,2}")
  message("一共有", pagenum, "个页面")
  # 注意：如果pagemun是NA，说明只有一个页面。跳过后面的循环。
  
  
  # 爬取首页文本
  txt <- htmlcode %>%
    html_nodes(".content") %>%
    html_text()
  message("爬取首页成功。。。")
  
  # 爬取接下来页面的文本（如果pagenum不是NA的话）
  # 网址就是city_start_url后面加上‘&pageno=2’ 。。
  if (!is.na(pagenum)){
    for (i in 2:pagenum) {
      url <- paste0(city_start_url, '&pageno=', i)
      txt_loop <- read_html(url, encoding = "GB18030") %>%
        html_nodes(".content") %>%
        html_text()
      txt <- paste(txt, txt_loop)
      
      message("正在爬取第", i, "页。。。")
    }
  }
  

  
  # 删除后面的 附：注：说明：注释：(责任编辑：admin)
  txt <- str_replace_all(txt, pattern = "\\(责任编辑：admin\\)", replacement = "")
  # pt <- "(注：(.|\n|\r)+)|(注释：(.|\n|\r)+$)|(说明：(.|\n|\r)+$)|(附：(.|\n|\r)+$)"
  # fu_num <- str_extract(txt, pattern = pt) %>% nchar() # match到的“附，注”的字数
  # total_num <- nchar(txt) # 删前总字数
  # 
  # if (fu_num > (total_num/3)) {
  #   nchar_info <- paste(city, year, "程序match到的附注字数超过总字数的1/3，不删除，请手动查看\n")
  # } else {
  #   nchar_info <- paste(city, year, "删除附注字数：", fu_num, "删除前总字数：", total_num, "\n")
  # }
  # txt <- str_replace_all(txt, pattern = pt, replacement = "")

 
  # 文本处理，写文件
  file_name <- paste0(city, "_", year, ".txt")
  cat(title, "\n", txt, file = file_name)
  # cat(nchar_info, file = "nchar.txt", append = TRUE)
  # 
  return(0)
}


# # 单元测试
# ScpCY("http://www.tjcn.org/plus/view.php?aid=23827")
# 






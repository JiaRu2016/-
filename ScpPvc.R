
# 输入：省份名称，例如“江苏省”
# 输出：
# 1. read.table "江苏省/江苏省_index.txt",
# 2.  for ....
#    Link = 
# 3. source(one_city_year.R)
# 4. ScpCY(Pvc, city_start_url = Link)


ScpPvc <- function(Pvc) {
  # input Pvc is char, eg. "四川省"
  
  project_wd <- "/Users/jiaru2014/Desktop/kalel/"
  
  setwd(project_wd)
  source("one_city_year.R")
  
  # 暂时把路径设置到“XX省”下
  setwd(file.path(project_wd, Pvc))
  
  # 读取 index 文件
  Pvc_list <- read.table(paste0(Pvc, "_index.txt"), header = TRUE)
  # Pvc_list
  
  for (i in 1:nrow(Pvc_list)) {
    
    NY <- paste(Pvc_list[i, "city"], Pvc_list[i, "years"])
    Link <- Pvc_list[i, "link"]
    Link <- paste0("http://www.tjcn.org", Link)
    
    tryCatch(
      {
        ScpCY(city_start_url = Link)
        message(NY, "成功~~")
      },
      error = function(e) {
        cat(NY, "爬取失败。。。", "\n", file = "log.txt", append = T)
      }
    )
    
  }
  
  # Use Mac terminal command to batch convert .txt files to .doc files
  system("textutil -convert doc *.txt")
  system("mkdir txtfiles")  # terminal command 新建文件夹
  system("mv *.txt txtfiles")  # terminal command move files
  
  
  # 恢复工作路径
  setwd(project_wd)
  
  return(0)
}

# 单元测试
ScpPvc("云南省")


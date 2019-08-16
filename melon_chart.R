rm(list=ls())

# 크롬 드라이버 버전 맞추기.  아래 링크로 확인
# https://ducj.tistory.com/m/14
# cd c:\selenium
# java -Dwebdriver.gecko.driver="geckodriver.exe" -jar selenium-server-standalone-3.9.0.jar -port 4446
# 3.6.0으로 하니까 충돌 문제 발생 3.9.0으로 바꿔서 설치하니까 잘 작동됨.
library(rvest)
library(stringr)
library(RSelenium)
library(rJava)
library(XML)

## 멜론 차트.

ch=wdman::chrome(port=4446L) #크롬드라이버를 포트 4567번에 배정
remDr=remoteDriver(remoteServerAddr = "localhost", port=4446L, browserName='chrome') #remort설정
remDr$open() #크롬 Open
remDr$navigate("https://www.amway.co.kr/business/record/report/business-achieve/reportPopup") #설정 URL로 이동
frontPage = remDr$getPageSource() #페이지 전체 소스 가져오기
frontPage
remDr$close() #크롬 Close

frontPage[[1]]
read_html(frontPage[[1]])


songNames = read_html(frontPage[[1]]) %>% html_nodes('.ellipsis.rank01') %>% html_text() #노래 이름 부분 추출하기 
songNames
songNames = gsub("\t","",songNames[c(2:101)]) #노이즈 글자 제거  
songNames
songNames = gsub("\n","",songNames) #노이즈 글자 제거 
songNames

songSingers = read_html(frontPage[[1]]) %>% html_nodes('.ellipsis.rank02') %>% html_text() #가수 이름 부분 추출하기 
songSingers
songSingers = gsub("\t","",songSingers[c(2:101)]) #노이즈 글자 제거 
songSingers
songSingers = gsub("\n","",songSingers) #노이즈 글자 제거 
songSingers = substring(songSingers,1,nchar(songSingers)/2) #글자가 2개씩 수집되서 앞의 1개만 잘라서 가져오기  
songSingers

#노래 번호가 할당되어 있어서 url로 접근이 가능함. 노래 번호만 가져오면 됨
songNums= read_html(frontPage[[1]]) %>% html_nodes('.btn.button_icons.type03.song_info') %>% html_attr('href') #노래 번호 부분 추출하기
songNums
songNums = gsub("javascript:melon.link.goSongDetail\\('","",songNums[c(2:101)]) #노이즈 글자 제거 
songNums
songNums = gsub("'\\);","",songNums) #노이즈 글자 제거 
songNums

melonResult = data.frame(Song=songNames, Singer=songSingers, Url=paste0("https://www.melon.com/song/detail.htm?songId=", songNums))

melonResult

links = melonResult[3]
links

links = as.character(links$Url)
class(links)
links






ch2=wdman::chrome(port=4568L) #크롬드라이버를 포트 4567번에 배정
remDr2=remoteDriver(port=4568L, browserName='chrome') #remort설정
remDr2$open() #크롬 Open
remDr2$navigate("https://www.melon.com/song/detail.htm?songId=31230093") #설정 URL로 이동
frontPage2 = remDr2$getPageSource() #페이지 전체 소스 가져오기
remDr2$close() #크롬 Close


song = read_html(frontPage2[[1]]) %>% html_nodes('.wrap_lyric')  #노래 가사 부분 추출하기
song

song = gsub("\t","",song) #노이즈 글자 제거  
song
song = gsub("\n","",song) #노이즈 글자 제거 
song
song = gsub("<br>"," ",song) #노이즈 글자 제거 
song
song = gsub("</div><button type=\"button\" title=\"Power Up 가사 더보기\" class=\"button_more arrow_d\" data-control=\"expose\" data-expose-type=\"more\" data-expose-target=\"#d_video_summary\"><span class=\"text\">펼치기</span><i class=\"button_icons etc arrow_d\"></i></button></div>","",song) #노이즈 글자 제거
song
song = gsub("<div class=\"wrap_lyric\"><div class=\"lyric\" id=\"d_video_summary\"><!-- height:auto; 로 변경시, 확장됨 -->"," ",song) #노이즈 글자 제거
song







############################

###############################

ch=wdman::chrome(port=4567L) #크롬드라이버를 포트 4567번에 배정
remDr=remoteDriver(port=4567L, browserName='chrome') #remort설정
remDr$open() #크롬 Open

for(i in 1:100){
  remDr$navigate(melonResult$Url[i]) #설정 URL로 이동
  frontPage = remDr$getPageSource() #페이지 전체 소스 가져오기
  
  songLyrics = read_html(frontPage[[1]]) %>% html_nodes('.wrap_lyric') %>% html_text() #노래 이름 부분 추출하기 
  songLyrics = gsub("\t","",songLyrics) #노이즈 글자 제거  
  songLyrics = gsub("\n","",songLyrics) #노이즈 글자 제거 
  
  melonResult[i,'Lyric'] = songLyrics
}

remDr$close() #크롬 Close

class(melonResult)

melonResult = gsub("https://www.melon.com/song/detail.htm?songId=" , "",  melonResult)
melonResult = gsub("\n" , "",  melonResult)
melonResult = gsub('' , '', melonResult)

melonResult

write.table(melonResult , "melon_txt.txt")
getwd()




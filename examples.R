# downloading public domain audio
url1 <- 'https://archive.org/download/adventuressherlockholmes_v4_1501_librivox/adventuresofsherlockholmes_01_doyle_128kb.mp3'
cmd1 <- paste0('cd ~/Downloads; wget -r -np -k ', url1)
system(cmd1)

setwd('~/Dropbox/D_Filipe_Zabala/pacotes/voiceAudios/')
cmd2 <- 'cd ~/Dropbox/D_Filipe_Zabala/pacotes/voiceAudios/; for i in *.[Mm][Pp]3; do ffmpeg -i "$i" "${i%.*}.wav"; done'
system(cmd2)

# libs
library(voice)
library(tidyverse)

# wd
setwd('~/Dropbox/D_Filipe_Zabala/pacotes/voiceAudios/')

# files and directories
wavDir <- paste0(getwd(), '/wav')
ifelse(!dir.exists(wavDir), dir.create(wavDir), 'Directory exists!')
wavFiles <- dir(wavDir, pattern = '[Ww][Aa][Vv]', full.names = T)
rttmDir <- paste0(getwd(), '/rttm')
splitDir <- paste0(getwd(), '/split')
ifelse(!dir.exists(rttmDir), dir.create(rttmDir), 'Directory exists!')
ifelse(!dir.exists(splitDir), dir.create(splitDir), 'Directory exists!')

# converting mp3 to wav
cmd3 <- 'cd ~/Dropbox/D_Filipe_Zabala/pacotes/voiceAudios/mp3;
for i in *.[Mm][Pp]3; do ffmpeg -i "$i" "../wav/${i%.*}.wav"; done'
system(cmd3)

# wav > mp3 > wav n times. spent time, cut accuracy, features accuracy
 # ffmpeg
 # tuneR?
 # audio?
 # ...?

# mp3 > wav n times. spent time, cut accuracy, features accuracy

# (who) speaks when?
ini <- Sys.time()
voice::wsw(wavDir, to = rttmDir, pycall = '~/miniconda3/envs/pyvoice38/bin/python3.8')
Sys.time()-ini # Time difference of 2.465053 mins

# split wave
ini <- Sys.time()
voice::splitw(wavDir, fromRttm = rttmDir, to = splitDir)
Sys.time()-ini # Time difference of 2.348608 secs

# extract features
ini <- Sys.time()
ef <- voice::extract_features(splitDir, round.to = 6)
Sys.time()-ini # Time difference of 5.082634 secs
ef

# creating tibble
ini <- Sys.time()
spl <- strsplit(ef$file_name, '[_.]')
Sys.time()-ini # Time difference of 3.261263 secs
names(spl) <- 1:length(spl)
spl <- bind_cols(spl)
spl <- t(spl)
ef$nome <- spl[,1]
ef <- ef %>%
  dplyr::relocate(file_name, nome, F0:MFCC12)
ef

# writing csv
ini <- Sys.time()
write_csv(ef, '~/Documents/lafa/ef.csv')
Sys.time()-ini # Time difference of 36.89806 secs

# exploratory
table(nome)
by(ef, ef$file_name, summary)

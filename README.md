# flac2alac

**flac2alac** is a shell script to convert FLAC (Free Lossless Audio Codec) files to ALAC (Apple Lossless Audio Codec) format, used on iPod/iPhone/iPad.

Dependencies:
- `ffmpeg`
- `file`
- `flac`
- `imagemagick`

``` sh
# To convert a single file
./flac2alac.sh file.flac

# To delete the original file after conversion
./flac2alac.sh -r file.flac

# To convert multiple FLAC files in the same directory
./flac2alac.sh *.flac

# To convert multiple FLAC files inside one directory nd its subfolders
./flac2alac.sh <directory_name>
```

---

```
flac2alac by Arlindo "Nighto" Pereira (C) 2010  
First posted on http://nighto.net/convertendo-flac-para-alac/  
Licensed on GPLv3  
also modified by Jeffrey Paul <sneak@datavibe.net>  
```

---

<details>
  <summary>Old README</summary>

  flac2alac by Arlindo "Nighto" Pereira (C) 2010  
  First posted on http://nighto.net/convertendo-flac-para-alac/  
  Licensed on GPLv3  
  also modified by Jeffrey Paul <sneak@datavibe.net>  

  flac2alac is a shell script to convert FLAC (Free Lossless Audio Codec) files to ALAC (Apple Lossless Audio Codec) format, used on iPod/iPhone/iPad.

  You can use it to convert a single .flac file to .m4a, like

    flac2alac file.flac

  You can use it to convert a directory of files:
 
    flac2alac *.flac

  You can use it to remove the original files after successful conversion:

    flac2alac -d *.flac

  Users of this program may find the "ppss" (parallel processing shell script) tool useful for converting large batches of files on modern, multi-core machines.

  Download at:  http://code.google.com/p/ppss/

  To convert an entire directory using all of your available cores:

    ppss -d . -c 'flac2alac '

  Or, to delete after:

    ppss -d . -c 'flac2alac -d '

  (One note: ppss by default recurses through all of the subdirectories of the directory specified by the '-d' option.  More info can be found in the ppss docs.)

  flac2alac uses flac and ffmpeg to decode/encode the audio files. On Ubuntu, you can install them with

  sudo apt-get install flac ffmpeg

  Also required is the mpeg4ip package that includes the mp4tags utility, fetch it from here:

  cvs -d:pserver:anonymous@mpeg4ip.cvs.sourceforge.net:/cvsroot/mpeg4ip login 
  cvs -d:pserver:anonymous@mpeg4ip.cvs.sourceforge.net:/cvsroot/mpeg4ip co -P mpeg4ip

  (their URL is http://mpeg4ip.sourceforge.net/downloads/index.php but they appear to have removed all tarball downloads.)

</details>
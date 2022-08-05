# Running repo on windows
## 1. Install Git bash  
    https://git-scm.com/download/win

## 2. Install python3  
    https://www.python.org/downloads/

## 3. Download repo from Google
    a. open git bash cmd prompt as administrator
    b. mkdir ~/bin
    c. curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
    d. chmod a+rx ~/bin/repo
    
## 4. Start to sync the code via repo  
    a. create a folder, such as mkdir android12_bsp
    b. cd android12_bsp
    c. repo init -u https://android.googlesource.com/platform/manifest -b android-12.1.0_r9
          after finished init, you will see like follos prompt
          repo has been initialized in D:\android12_bsp\
          If this is not the directory in which you want to initialize repo, please run:
          rm -r D:\android12_bsp\/.repo
          and try again.
          Downloading Repo source from https://gerrit.googlesource.com/git-repo
    d. repo sync
    
## Error.  
    a. cd .repo
    b. rm -rf repo
    c. git clone https://gerrit.googlesource.com/git-repo
    d. mv git-repo repo
    e. back to top folder, and do repo sync

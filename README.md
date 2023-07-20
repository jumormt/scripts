# Some useful scripts


- For ubuntu, give the script execution permission:

```sh
chmod +x script
```

e.g., `chmod +x tm`

## [Collect time and memory of a process](https://github.com/jumormt/scripts/blob/main/tm)

- Use the script:

```sh
./tm your_commind_line
```

e.g. `./tm saber -leak -stat=false saber.bc`

alternatively, run in background and record in `your_log`:

```sh
nohup ./tm your_commind_line > your_log &
```

e.g. `nohup ./tm saber -leak -stat=false saber.bc  > saber.log &`

## [gitsearch](https://github.com/jumormt/scripts/blob/main/gitsearch)

- enter the root of the git repo
- gitsearch

```sh
./gitsearch overflow|null
```

It will print the commits containing the keywords and write to "overflow.commits" or "null.commits"
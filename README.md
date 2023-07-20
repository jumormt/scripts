# Some useful scripts

## [Collect time and memory of a process](https://github.com/jumormt/scripts/blob/main/tm)

> ubuntu

- Give the script execution permission:

```sh
chmod +x tm
```

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

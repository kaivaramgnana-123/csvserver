# CSV Server Assignment - Part I

## Commands Executed

1. **Initial container run (failed - missing input file)**
   ```bash
   docker run -d --name csvserver infracloudio/csvserver:latest
   docker logs csvserver
   # Error: error while reading the file "/csvserver/inputdata"

# DROWNDetectionTool
A small script to detect the DROWN vuln.

```
./DROWNDetectionTool.sh [-p PORT] targets ...

    -p  port number to contact on target
        defaults to 443 (HTTPS)

examples
    # test port 6697 on example.con
    ./DROWNDetectionTool.sh -p 6697 example.com

    # test port 443 on each target in targets.txt (one per line)
    cat targets.txt | ./DROWNDetectionTool.sh

    # same as above without a pipeline
    ./DROWNDetectionTool.sh targets.txt
```

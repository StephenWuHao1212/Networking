This is the program for server-client homework. It allows multiple clients connecting to server concurrently.

Online source:
online manpage: http://man7.org/linux/man-pages/index.html

Tests case:
1) For one client mode, tests included 1-byte, 5-bytes, 20-bytes, 512-bytes and 520-bytes message. It will work even when message length exceeds 520 bytes. And I also tested those cases with a disconnect-reconnect client.
2) For multiple clients mode. I tested the above cases in all clients(number of clients is up to 5, the server will not work when the number exceeds). And the program is tested with disconnect-reconnect case.
3) all test command is tested by port number 1040, 1050 and 9999 with 127.0.0.1

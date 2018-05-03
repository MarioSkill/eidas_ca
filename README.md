**eidas_ca**

*1) How to build Docker*
=========================
__docker build -t eidas_ca pathToDockerfile__

*2) How to launch the  docker*
=========================
__docker run -it -p 8080:8080 eidas_ca_2 /bin/bash__
Next, we need to do: 
.\changeIP.sh PUBLIC_IP and then .\start

*3) How to test it*
=========================
Open web browser, go to PUBLIC_IP:8080/SP. If you have successfully completed these steps, you should see a screen like this
 ![eIDAS SP Home Page](https://raw.githubusercontent.com/MarioSkill/eidas_ca/master/eidas.png)

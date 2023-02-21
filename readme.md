To set up atlantis for a terraform project, you need the following:
1. Your github token
2. A random secret string
3. Atlantis
4. Ngrok
5. Your github username 
6. The github repo you want to integrate with atlantis

### Installing Atlantis, Ngrok and generating a random string. 
I used the script below to install on linux and also generate the strings.

```
#!/bin/sh
set -e

ATLANTIS_VERSION=v0.19.4
ATLANTIS_PACKAGE=atlantis_linux_386.zip

echo "Download Atlantis library"
wget https://github.com/runatlantis/atlantis/releases/download/${ATLANTIS_VERSION}/${ATLANTIS_PACKAGE}
unzip atlantis_linux_386.zip

echo "Download ngrok"
wget -c https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-386.tgz -O - \
        | tar -xz

echo "Generate random secret string"
echo $RANDOM | md5sum | head -c 20; echo;
```
After running the above script, save the generated random string as it will be used later on. It is advisable that you sign up on ngrok on their website. Afterward, go on the authtoken page to configure your authtoken on the command line for ngrok
https://dashboard.ngrok.com/get-started/your-authtoken

On your terminal, run the command 
```
./ngrok http 4141
```
The link you get as the forwarding value after running the above command i.e the link highlighted in the image below will also be used.
![](https://github.com/Makinates/anotheratlantis/blob/main/Images/Screenshot%20from%202022-12-07%2010-39-01.png)

### Webhook Setup
Now, go to the settings of your repository and create a webhook then do the following:
1. In payload url, put the forwarding url you got from ngrok above with "/events" as the suffix
2. Under content type, select application json
3. under secrets, put the random secret string that was generated
4. select "Let me specify individual events" and specify the following events: issue comments, pull request reviews, pushes and pull requests.
Just like the images below:
![](https://github.com/Makinates/anotheratlantis/blob/main/Images/Screenshot%20from%202022-12-07%2010-46-01.png)
![](https://github.com/Makinates/anotheratlantis/blob/main/Images/Screenshot%20from%202022-12-07%2010-46-13.png)

Now, that all these have been set up, we will use the following script where we will specify the values we listed in the beginning.

```
#!/bin/sh
set -e

SECRET=68b329da9893e34099c7
TOKEN=
URL=https://c1f1-102-89-46-140.eu.ngrok.io
USERNAME=omolade11
REPO_ALLOWLIST="github.com/Omolade11/atlantis-setup"


./atlantis server \
--atlantis-url="$URL" \
--gh-user="$USERNAME" \
--gh-token="$TOKEN" \
--gh-webhook-secret="$SECRET" \
--repo-allowlist="$REPO_ALLOWLIST" \
```

I removed my github token above, you should specify yours in the script.
The "atlantis-url" in this case is the ngrok url we got earlier
The "gh-user" is the github username
The "gh-token" is the github token
The "gh-webhook-secret" is the random secret string we generated and we kept in our repo's webhook earlier
The "repo-allowlist" is the github repo we want atlantis to be activated in.

After inputting the right values and running the script, go and create a pull request and the repository and you will see atlantis automatically run an "atlantis plan" on the pull request. You can comment "atlantis apply" if you want to see the resources applied to your aws account. In this case, the aws credential specified was done with "aws configure" in the terminal before pushing the infrastructure code to github. 

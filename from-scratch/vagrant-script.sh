cp fresh-setup.sh ~/setup.sh
chmod +x ~/setup.sh
echo 'if [ -f ~/setup.sh ]; then 
	~/setup.sh && rm ~/setup.sh 
fi' >> ~/.bashrc
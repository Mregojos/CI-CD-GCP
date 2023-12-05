# sh g* 
# sh git-push.sh
# https://github.com/mregojos/CI-CD-GCP

# For Security
# Cleanup environment variables
rm -f ./.env.*
rm -f ./*/.env.*
rm -f ./*/*/.env.*
rm -f ./*/*/*/.env.*
rm -f ./*/*/*/*/.env.*
rm -rf .ipynb_checkpoints
rm -rf ./*/.ipynb_checkpoints
rm -rf ./*/*/.ipynb_checkpoints
echo "Successfully removed .env.* and checkpoints files ready to be pushed to repository."
sed -i 's/export ADMIN_PASSWORD=".*"/export ADMIN_PASSWORD=""/g' environment-variables.sh 
sed -i 's/export DB_PASSWORD=".*"/export DB_PASSWORD=""/g' environment-variables.sh 
sed -i 's/export SPECIAL_NAME=".*"/export SPECIAL_NAME=""/g' environment-variables.sh
sed -i 's/export ADMIN_PASSWORD=".*"/export ADMIN_PASSWORD=""/g' app/startup-script.sh 
sed -i 's/export DB_PASSWORD=".*"/export DB_PASSWORD=""/g' app/startup-script.sh 

git add .
# git config --global user.email "<EMAIL_ADDRESS>"
# git config --global user.email ""
git config --global user.name "Matt"
git commit -m "Add and modify files"
git push

# username
# password

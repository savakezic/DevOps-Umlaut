# simpphpweb2.com
# 2nd dynamic content deliverer

server {
	listen 8002;
	
	server_name simpphpweb2.com;

	root /var/www/simpphpweb;

	# Add index.php to the list if you are using PHP
	index index.html index.php;


	location / {
		# First attempt to serve request as file, then
		# as directory, then fall back to displaying a 404.
		try_files $uri $uri/ =404;
	}

	# pass PHP scripts to FastCGI server
	
	location ~ \.php$ {
    	try_files $uri =404;
    	fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
    	fastcgi_index index.php;
    	fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    	include fastcgi_params;
  }


}


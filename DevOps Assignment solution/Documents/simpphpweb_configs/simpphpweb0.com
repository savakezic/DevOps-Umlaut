# simpphpweb0.com
# load balancer and static content deliverer

#log_format upstream '$server_name to $upstream_addr';

upstream dservers {
	server simpphpweb1.com:8001;
	server simpphpweb2.com:8002;
}

server {
	listen 80;

	server_name simpphpweb0.com;

	root /var/www/simpphpweb;

	access_log /var/www/simpphpweb/access.log combined;
	#access_log /var/www/simpphpweb/upstream.log upstream;

	error_log /var/www/simpphpweb/error.log warn;

	# Add index.php to the list if you are using PHP
	index index.html index.php;

	location /static {
		#locating and retriving static content

		# First attempt to serve request as file, then
		# as directory, then fall back to displaying a 404.
		try_files $uri $uri/ =404;
	}

	location / {
		#passing to dynamic dservers
		proxy_pass http://dservers;
		
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


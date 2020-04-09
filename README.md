# Mediasoup-demo-cloud

It's a  demo application of [mediasoup](https://mediasoup.org/) **v3**,base on docker. 

this docker alread included nginx model. 

## Resources

- mediasoup website and documentation: [mediasoup.org](https://mediasoup.org/)
- mediasoup support forum: [mediasoup.discourse.group](https://mediasoup.discourse.group/)
- Mediasoup-demo-cloud :[[github](https://github.com/ysf465639310/CLOUD_MEDIASOUP)]

## ENV Variables

- [DEBUG](https://github.com/versatica/mediasoup-demo/blob/v3/server/DOCKER.md#debug)
- [DOMAIN](https://github.com/versatica/mediasoup-demo/blob/v3/server/DOCKER.md#domain)
- [PROTOO_LISTEN_PORT](https://github.com/versatica/mediasoup-demo/blob/v3/server/DOCKER.md#protoo_listen_port)
- [MEDIASOUP_LISTEN_IP](https://github.com/versatica/mediasoup-demo/blob/v3/server/DOCKER.md#mediasoup_listen_ip)
- [MEDIASOUP_ANNOUNCED_IP](https://github.com/versatica/mediasoup-demo/blob/v3/server/DOCKER.md#mediasoup_announced_ip)
- [MEDIASOUP_MIN_PORT](https://github.com/versatica/mediasoup-demo/blob/v3/server/DOCKER.md#mediasoup_min_port)
- [MEDIASOUP_MAX_PORT](https://github.com/versatica/mediasoup-demo/blob/v3/server/DOCKER.md#mediasoup_max_port)
- [MEDIASOUP_USE_VALGRIND](https://github.com/versatica/mediasoup-demo/blob/v3/server/DOCKER.md#mediasoup_use_valgrind)
- [MEDIASOUP_VALGRIND_OPTIONS](https://github.com/versatica/mediasoup-demo/blob/v3/server/DOCKER.md#mediasoup_valgrind_options)

## DockerCompose info

##### mediasoup worker docker-compose.yml

```yaml
version: '3'

services:
    # Frontend
    mediasoupFrontend:
        image: ysf465639310/mediasoup-demo-cloud:v2
        ports:
            - 9443:9443
            - 3000:3000
            
        working_dir: /mediasoup/public
        
        privileged: true
        
        volumes:
            - /etc/localtime:/etc/localtime
            - ../../config/config.js:/mediasoup/config/config.js:rw
            - ../../config/config.js:/mediasoup/server/config.js:rw
            - ../../config/nginx.conf:/etc/nginx/nginx.conf:rw
            - ../nginx:/run/nginx
            
        env_file:
            - ./media.env
        
        command: ["nginx","-c", "/etc/nginx/nginx.conf", "-g", "daemon off;"]
        
        
        networks:
             cloud_conference:
                ipv4_address: 172.88.0.2
                
    # mediasoup-worker
    mediasoup:
        image: ysf465639310/mediasoup-demo-cloud:v2
        ports:
            - '${PROTOO_LISTEN_PORT}:${PROTOO_LISTEN_PORT}'
            - '${MEDIASOUP_MIN_PORT}-${MEDIASOUP_MAX_PORT}:${MEDIASOUP_MIN_PORT}-${MEDIASOUP_MAX_PORT}/udp'
            - '${MEDIASOUP_MIN_PORT}-${MEDIASOUP_MAX_PORT}:${MEDIASOUP_MIN_PORT}-${MEDIASOUP_MAX_PORT}/tcp'
        working_dir: /mediasoup/server/
        
        #if you want your own config,you can use volume lis this
        volumes:
          - /etc/localtime:/etc/localtime
          - ../../config/config.js:/mediasoup/config/config.js:rw
          - ../../config/config.js:/mediasoup/server/config.js:rw
              # - ../data:/data
              #- ../storage:/storage
            
        env_file:
            - ./media.env
        
        command:  ["node", "./server.js"]
        #command: ["sleep", "10000000"]
        
        networks:
             cloud_conference:
                ipv4_address: 172.88.0.3
networks:
   cloud_conference:
      ipam:
         config:
         - subnet: 172.88.0.0/16
           #gateway: 172.88.0.1

```



## Run mediasoup server with Docker

1. Step1: 

   ```bash
   root@H3CDATA:/opt/CLOUD_MEDIASOUP# cd mediasoup/compose/
   root@H3CDATA:/opt/CLOUD_MEDIASOUP/mediasoup/compose# mv media.env .env
   ```

2. Step2

   ```bash
   root@H3CDATA:/opt/CLOUD_MEDIASOUP/mediasoup/compose# docker-compose up -d
   ```



##### Files list

```bash
root@iZbp11cvux96rhu0netj6aZ:/opt/CLOUD_CONFERENCEV1/mediasoup/compose# ll 
total 20
drwxr-xr-x 2 root root 4096 Apr  9 12:05 ./
drwxr-xr-x 5 root root 4096 Apr  2 09:20 ../
-rw-r--r-- 1 root root 1075 Apr  9 12:05 docker-compose.yml
-rw-r--r-- 1 root root  465 Apr  2 09:20 .env
-rw-r--r-- 1 root root  463 Apr  2 09:20 media.env
root@iZbp11cvux96rhu0netj6aZ:/opt/CLOUD_CONFERENCEV1/mediasoup/compose# 
```

```bash
root@iZbp11cvux96rhu0netj6aZ:/opt/CLOUD_CONFERENCEV1# ll 
total 32
drwxr-xr-x 8 root root 4096 Apr  7 14:40 ./
drwxr-xr-x 6 root root 4096 Apr  7 14:45 ../
drwxr-xr-x 3 root root 4096 Apr  2 09:20 config/
drwxr-xr-x 5 root root 4096 Apr  2 09:20 mediasoup/
```

##### config.js file

```javascript
/**
 * IMPORTANT (PLEASE READ THIS):
 *
 * This is not the "configuration file" of mediasoup. This is the configuration
 * file of the mediasoup-demo app. mediasoup itself is a server-side library, it
 * does not read any "configuration file". Instead it exposes an API. This demo
 * application just reads settings from this file (once copied to config.js) and
 * calls the mediasoup API with those settings when appropriate.
 *
 */

const os = require('os');

module.exports =
{
	// Listening hostname (just for `gulp live` task).
	domain : process.env.DOMAIN || '0.0.0.0',
	// Signaling settings (protoo WebSocket server and HTTP API server).
	https  :
	{
		listenIp   : '0.0.0.0',
		// NOTE: Don't change listenPort (client app assumes 4443).
		listenPort : process.env.PROTOO_LISTEN_PORT || 4443,
		// NOTE: Set your own valid certificate files.
		tls        :
		{
			cert : process.env.HTTPS_CERT_FULLCHAIN || `${__dirname}/certs/fullchain.pem`,
			key  : process.env.HTTPS_CERT_PRIVKEY || `${__dirname}/certs/privkey.pem`
		}
	},
	// mediasoup settings.
	mediasoup :
	{
		// Number of mediasoup workers to launch.
		numWorkers : Object.keys(os.cpus()).length,
		// mediasoup WorkerSettings.
		// See https://mediasoup.org/documentation/v3/mediasoup/api/#WorkerSettings
		workerSettings :
		{
			logLevel : 'warn',
			logTags  :
			[
				'info',
				'ice',
				'dtls',
				'rtp',
				'srtp',
				'rtcp',
				'rtx',
				'bwe',
				'score',
				'simulcast',
				'svc',
				'sctp'
			],
			rtcMinPort : process.env.MEDIASOUP_MIN_PORT || 40000,
			rtcMaxPort : process.env.MEDIASOUP_MAX_PORT || 49999
		},
		// mediasoup Router options.
		// See https://mediasoup.org/documentation/v3/mediasoup/api/#RouterOptions
		routerOptions :
		{
			mediaCodecs :
			[
				{
					kind      : 'audio',
					mimeType  : 'audio/opus',
					clockRate : 48000,
					channels  : 2
				},
				{
					kind       : 'video',
					mimeType   : 'video/VP8',
					clockRate  : 90000,
					parameters :
					{
						'x-google-start-bitrate' : 1000
					}
				},
				{
					kind       : 'video',
					mimeType   : 'video/VP9',
					clockRate  : 90000,
					parameters :
					{
						'profile-id'             : 2,
						'x-google-start-bitrate' : 1000
					}
				},
				{
					kind       : 'video',
					mimeType   : 'video/h264',
					clockRate  : 90000,
					parameters :
					{
						'packetization-mode'      : 1,
						'profile-level-id'        : '4d0032',
						'level-asymmetry-allowed' : 1,
						'x-google-start-bitrate'  : 1000
					}
				},
				{
					kind       : 'video',
					mimeType   : 'video/h264',
					clockRate  : 90000,
					parameters :
					{
						'packetization-mode'      : 1,
						'profile-level-id'        : '42e01f',
						'level-asymmetry-allowed' : 1,
						'x-google-start-bitrate'  : 1000
					}
				}
			]
		},
		// mediasoup WebRtcTransport options for WebRTC endpoints (mediasoup-client,
		// libmediasoupclient).
		// See https://mediasoup.org/documentation/v3/mediasoup/api/#WebRtcTransportOptions
		webRtcTransportOptions :
		{
			listenIps :
			[
				{
					ip          : process.env.MEDIASOUP_LISTEN_IP || '127.0.0.1',
					announcedIp : process.env.MEDIASOUP_ANNOUNCED_IP || '0.0.0.0'
				}
			],
			initialAvailableOutgoingBitrate : 1000000,
			minimumAvailableOutgoingBitrate : 600000,
			maxSctpMessageSize              : 262144,
			// Additional options that are not part of WebRtcTransportOptions.
			maxIncomingBitrate              : 1500000
		},
		// mediasoup PlainTransport options for legacy RTP endpoints (FFmpeg,
		// GStreamer).
		// See https://mediasoup.org/documentation/v3/mediasoup/api/#PlainTransportOptions
		plainTransportOptions :
		{
			listenIp :
			{
				ip          : process.env.MEDIASOUP_LISTEN_IP || '127.0.0.1',
				announcedIp : process.env.MEDIASOUP_ANNOUNCED_IP || '0.0.0.0'
			},
			maxSctpMessageSize : 262144
		}
	}
};
```

##### ENV config

```bash
#media.env
DOMAIN=47.114.54.xxxx  #your host ip
MEDIASOUP_LISTEN_IP=172.88.0.3 #docker ip
MEDIASOUP_ANNOUNCED_IP=47.114.54.xxx #your host ip
DEBUG=*mediasoup* *ERROR* *WARN*
INTERACTIVE=false
PROTOO_LISTEN_PORT=4443
HTTPS_CERT_FULLCHAIN=/mediasoup/config/certs/fullchain.pem
HTTPS_CERT_PRIVKEY=/mediasoup/config/certs/privkey.pem
MEDIASOUP_MIN_PORT=30000
MEDIASOUP_MAX_PORT=30100
MEDIASOUP_USE_VALGRIND=false
MEDIASOUP_VALGRIND_OPTIONS=--leak-check=full --track-fds=yes --log-file=/storage/mediasoup_valgrind_%p.log
```

##### nginx config

```nginx
worker_processes  auto;
#error_log  logs/error.log;

events {
    worker_connections  1024;
}

http {
        sendfile off;
        tcp_nopush on;
        directio 512;
        include   /etc/nginx/mime.types;
        # aio on;

        # HTTP server required to serve the player and HLS fragments
        server {
                listen 9443;
                ssl_certificate     /mediasoup/config/certs/fullchain.pem;
                ssl_certificate_key /mediasoup/config/certs/privkey.pem;
                ssl_session_cache   shared:SSL:10m;
                ssl_session_timeout 10m;
                ssl on;
                location /{
                        root /mediasoup/public;
            try_files $uri /index.html;
            index index.html index.htm index.php;
        }
                location ~* \.(css|gif|ico|jpg|js|png|ttf|woff)$ {
                        root /mediasoup/public;
                }
                location ~* \.(eot|otf|ttf|woff|svg)$ {
            add_header Access-Control-Allow-Origin *;
                        root /mediasoup/public;
         }
        }
}

```

## Authors

yangshaofei[[github](https://github.com/ysf465639310/)]

## License

MIT
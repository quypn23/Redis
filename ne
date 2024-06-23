version: '3.8'

services:
  redis-master1:
    image: redis:latest
    container_name: redis-master1
    command: redis-server /usr/local/etc/redis/redis.conf
    ports:
      - "6379:6379"
    volumes:
      - redis-master-data1:/data
      - ./redis-master.conf:/usr/local/etc/redis/redis.conf
      - /var/log/redis:/data/log/redis
    networks:
      redis-net:
        ipv4_address: 172.20.0.10
  redis-master2:
    image: redis:latest
    container_name: redis-master2
    command: redis-server /usr/local/etc/redis/redis.conf
    ports:
      - "6380:6379"
    volumes:
      - redis-master-data2:/data
      - ./redis-master.conf:/usr/local/etc/redis/redis.conf
      - /var/log/redis:/data/log/redis
    networks:
      redis-net:
        ipv4_address: 172.20.0.11
  redis-master3:
    image: redis:latest
    container_name: redis-master3
    command: redis-server /usr/local/etc/redis/redis.conf
    ports:
      - "6381:6379"
    volumes:
      - redis-master-data3:/data
      - ./redis-master.conf:/usr/local/etc/redis/redis.conf
      - /var/log/redis:/data/log/redis
    networks:
      redis-net:
        ipv4_address: 172.20.0.12

  redis-slave-1:
    image: redis:latest
    container_name: redis-slave-1
    command: redis-server /usr/local/etc/redis/redis.conf
    volumes:
      - redis-slave-data-1:/data
      - ./redis-slave.conf:/usr/local/etc/redis/redis.conf
    networks:
      redis-net:
        ipv4_address: 172.20.0.13
    depends_on:
      - redis-master1
      - redis-master2
      - redis-master3
  redis-slave-2:
    image: redis:latest
    container_name: redis-slave-2
    command: redis-server /usr/local/etc/redis/redis.conf
    volumes:
      - redis-slave-data-2:/data
      - ./redis-slave.conf:/usr/local/etc/redis/redis.conf
    networks:
      redis-net:
        ipv4_address: 172.20.0.15
    depends_on:
      - redis-master1
      - redis-master2
      - redis-master3
  redis-slave-3:
    image: redis:latest
    container_name: redis-slave-3
    command: redis-server /usr/local/etc/redis/redis.conf
    volumes:
      - redis-slave-data-3:/data
      - ./redis-slave.conf:/usr/local/etc/redis/redis.conf
    networks:
      redis-net:
        ipv4_address: 172.20.0.16
    depends_on:
      - redis-master1
      - redis-master2
      - redis-master3
  redis-sentinel:
    image: redis:latest
    container_name: redis-sentinel
    command: redis-sentinel /usr/local/etc/redis/sentinel.conf --sentinel
    ports:
      - "26379:26379"
    volumes:
      - ./sentinel.conf:/usr/local/etc/redis/sentinel.conf
    networks:
      redis-net:
        ipv4_address: 172.20.0.17
    depends_on:
      - redis-master1
      - redis-master2
      - redis-master3
      - redis-slave-1
      - redis-slave-2
      - redis-slave-3

  haproxy:
    image: haproxy:latest
    container_name: haproxy
    volumes:
      - ./haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg
    ports:
      - "6389:6379"
    networks:
      redis-net:
        ipv4_address: 172.20.0.14
    depends_on:
      - redis-master1
      - redis-master2
      - redis-master3
      - redis-slave-1
      - redis-slave-2
      - redis-slave-3

volumes:
  redis-master-data1:
  redis-master-data2:
  redis-master-data3:
  redis-slave-data-1:
  redis-slave-data-2:
  redis-slave-data-3:

networks:
  redis-net:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16

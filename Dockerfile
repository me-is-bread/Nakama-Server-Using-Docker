FROM ubuntu:latest

RUN mkdir -p /nakama/data

ADD ./data/config.yml /nakama/
ADD ./nakama /nakama

RUN chmod +x /nakama/nakama
CMD /nakama/nakama --database.address "postgresql://firstgamesData:bNVY9azk_rGQHfGCLpFeqQ@free-tier12.aws-ap-south-1.cockroachlabs.cloud:26257/defaultdb?options=--cluster%3Dfirstgames-813" migrate up

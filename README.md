# amrs-docker-test
Replica of ampath amrs setup with all the modules and sample data as a docker image

# To run

```git clone https://github.com/AMPATH/amrs-docker-test ```

``` cd amrs-docker-test ```

``` tar zxvf data.tar.gz ```

``` sudo docker build -t ampath/amrs-test . ```

``` cp main.env.example  main.env```

``` docker composer up ```


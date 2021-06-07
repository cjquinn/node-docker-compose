# Setup

For a good overview of what Docker is and how to get setup with it check out the [official documentation](https://docs.docker.com/get-started/). Also have a good look around the application code and feel free to ask any questions about it.

# 1 - Building an image

In order to run our application we need Node.js, specifically version 10. Lets also assume that it is not possible to install Node.js on our computer or that it is much more difficult then it actually is! This is where Docker images come in, we can create an image that has Node.js installed and is able to run our application. We can then use this image to start a container, which you can think of as a process, and it will be running our application.

Images are built by creating a [`Dockerfile`](https://docs.docker.com/engine/reference/builder/) and using the [docker build](https://docs.docker.com/engine/reference/commandline/build/) command, at this point you can also give it a name amongst other properties.

One handy thing you can do when creating your own images is extend pre-existing ones. You can use [docker hub](https://hub.docker.com/) to search for potential starting points. For example you could start with the [Alpine](https://hub.docker.com/_/alpine) image which is a super small implementation of Alpine Linux. You could then install Node.js and anything else you needed (There might also be a quicker way :)).

Another thing an image can have is a command. You can think of this as the executable of the image or the entry point. In a `Dockerfile` it is normally the last line and when you start a container is what we be ran. For example if we wanted our container to start a node process we might add `CMD ["node", "server.js"]`.

## Requirements

- [Node.js v10](https://nodejs.org/en/blog/release/v10.0.0/)
- [nodemon](https://www.npmjs.com/package/nodemon)
- A command to start our application - check [`package.json`](package.json) for what this might be

## Hints

- Starting from another image that gives you a lot of what you need is always best - https://docs.docker.com/engine/reference/builder/#from
- It is super simple to copy your local files into a container - https://docs.docker.com/engine/reference/builder/#copy
- Specifying what directory you are working in is very handy - https://docs.docker.com/engine/reference/builder/#workdir
- When it comes to running your image in a container you will need to expose the port our application is running on to one locally - https://docs.docker.com/engine/reference/run/#expose-incoming-ports

## Testing

Once you have built your image and enter your `docker run` command you should be able to go to http://localhost in your browser. You might notice nothing happens in the browser but your command line goes wild!

## Resources:

- How to build and run an image - https://docs.docker.com/get-started/part2/
- `Dockerfile` reference - https://docs.docker.com/engine/reference/builder/
- Command to build an image - https://docs.docker.com/engine/reference/commandline/build/
- Command to run a container - https://docs.docker.com/engine/reference/run/

## Solution

### `Dockerfile`

```
FROM node:10

WORKDIR /usr/src/app

COPY . .

RUN npm i
RUN npm i -g nodemon

CMD ["npm", "start"]
```

```
docker build -t node-docker-compose .
docker run -p 80:3000 node-docker-compose
```

# 2 - We need a database

After running the image built in the previous step - `docker run your-image-name -p 80:3000` - you might notice that it still doesn't work when you go to http://localhost in your browser. This is because it needs a database! We are using [PostgreSQL](https://www.postgresql.org/) as our database system. Just like with Node.js lets assume our computer can't run it or that there is some configuration specific to our application that we want to distribute.

Fortunately for us there is a [Postgres Docker image](https://hub.docker.com/_/postgres). Give this page a read and see if you can get Postgres running in a container.

## Requirements

- Postgres running
- SQL in `./docker-entrypoint-initdb.d` is ran when starting the container

## Hints

- This can be completed in one `docker run` command
- You will need to add the `./docker-entrypoint-initdb.d` as a volume - https://docs.docker.com/engine/reference/run/#volume-shared-filesystems

## Testing

Edit your `docker run` command to name the container `postgres-test` - `docker run --name postgres-test {the rest of your command}` - then run the following command in a separate terminal window to run a query against our Postgres database.

```
docker exec test-postgres psql -U postgres -d postgres -c "select * from teams"
```

This should output the following:

```
 id |                   name                   | position
----+------------------------------------------+----------
  1 | AG2R La Mondiale                         |        1
  2 | EF Education First–Drapac p/b Cannondale |        2
  3 | BMC Racing Team                          |        3
  4 | Team Dimension Data                      |        4
  5 | Bahrain–Merida                           |        5
  6 | Team Katusha–Alpecin                     |        6
  7 | Bora–Hansgrohe                           |        7
  8 | Astana                                   |        8
(8 rows)
```

## Resources:

- Postgres Docker image - https://hub.docker.com/_/postgres
- Command to run a container - https://docs.docker.com/engine/reference/run/

## Solution

```
docker run -it --rm --name test-postgres -v "$PWD"/docker-entrypoint-initdb.d:/docker-entrypoint-initdb.d -e POSTGRES_PASSWORD=secret postgres
```

# 3 - Putting it all together

So our application still doesn't work... We have our Node.js server and our database but they can't talk to each other. Also remembering all the commands is a pain! Enter [`docker-compose`](https://docs.docker.com/compose/compose-file/). Using `docker-compose` we can easily configure a set of services and run them as containers with the command `docker-compose up`.

The other issue with how we were configuring our Node.js image is we were copying the files into it before building. This means that if we made a change to our application we would have to rebuild the image...not very good for local development! Fortunately it is possible to add our files as a volume to a container. You can think of this as symlinking our files to a location in the container.

## Requirements

- Node.js service configured
- Postgres service configured
- A network that allows them to communicate
- Optional - a volume to persist your database data

## Hints

- You will notice in [`app.js`](app.js) that the host in the database connection string is `db`. This should be the key you use for the Postgres service and it is then the host that you can use to communicate between containers of the same network
- For your Node.js service instead of an image you can configure it to build from a `Dockerfile` - https://docs.docker.com/compose/compose-file/#build
- You should remove the `COPY` line that is in your `Dockerfile` and configure a volume instead - https://docs.docker.com/compose/compose-file/#volumes-for-services-swarms-and-stack-files
- You should remove the `CMD` line that is in your `Dockerfile` and add it as configuration for your Node.js service - https://docs.docker.com/compose/compose-file/#command

## Testing

Finally we are here! Run `docker-compose up` and go to http://localhost in your browser. Because we have added our files as a volume you can also make changes to the Node.js code and they will be reflected when you refresh the page.

## Resources:

- Everything `docker-compose` - https://docs.docker.com/compose/compose-file/

## Solution

```
version: "3.8"
services:
  node:
    build:
      context: .
    command: npm start
    ports:
     - ${TARGET_PORT}:${APP_PORT}
    volumes:
     - .:/usr/src/app
    networks:
     - network
  db:
    image: postgres
    environment:
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
     - ./docker-entrypoint-initdb.d:/docker-entrypoint-initdb.d
     - data:/var/lib/postgresql/data
    networks:
     - network
networks:
  network:
    driver: bridge
volumes:
  data:
    driver: local
```

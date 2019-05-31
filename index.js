/*const app = require('http').createServer((req, res) => {
    require("fs").createReadStream(require("path").join(__dirname, "../2048/index.html")).pipe(res);
});
*/

var express = require('express');
var app = express();
app.use(express.static(__dirname + '../2048'))

app.get("/", (req, res) => {
  res.sendFile(require("path").join(__dirname, "index.html"));
});

app.use('/2048', express.static('../2048'))


const server = app.listen(80);

const io = require('socket.io')(server);

const sockets = {};

io.on('connection', (socket) => {
	sockets[socket.id] = socket;

    console.log("connection!");
    //console.log(socket);

	socket.on('message', (message) => {
		console.log(`got ${message}`);
	});

    socket.on('play', (settings) => {
        console.log('starting new game with settings:' + settings)
        const { spawn } = require('child_process');
        const p = require("path").join(__dirname, ".build/x86_64-unknown-linux/debug/2048AI")
        const game = spawn('unbuffer', ['-p', p]);
        //const game = spawn('../2048AI/.build/x86_64-apple-macosx10.10/debug/2048AI');
        //const settings = spawn('cat', ['../2048AI/settings']);

        //console.log(game)

        s = JSON.parse(settings)

        game.stdin.write(s.w11[0] + " " + s.w12[0] + " " + s.w13[0] + " " + s.w14[0] + "\n");
        game.stdin.write(s.w21[0] + " " + s.w22[0] + " " + s.w23[0] + " " + s.w24[0]+ "\n");
        game.stdin.write(s.w31[0] + " " + s.w32[0] + " " + s.w33[0] + " " + s.w34[0]+ "\n");
        game.stdin.write(s.w41[0] + " " + s.w42[0] + " " + s.w43[0] + " " + s.w44[0]+ "\n");

        game.stdin.write(s.emptyBonus[0]+ "\n")
        game.stdin.write(s.smoothBonus[0]+ "\n")

        game.stdin.write(s.prob2[0]+ "\n")
        game.stdin.write(s.prob4[0]+ "\n")

        game.stdin.write((parseInt(s.depth[0])-1).toString() + "\n")
        game.stdin.write(s.samplingAmount[0]+ "\n")


        console.log('wrote settings to game')
        /*settings.stdout.on('data', (data) => {
            game.stdin.write(data)
        });*/

        var readline = require('readline');
        readline.createInterface({
            input: game.stdout,
            terminal: false
        }).on('line', function(line){
            obj = JSON.parse(line);
            //console.log(obj);
            socket.emit('turn', obj);
            if (obj.type == "move"){
             //   console.log("making move");
                socket.emit('move', obj.dir);
            }
            if (obj.type == "place"){
              //  console.log("making place");
                socket.emit('place', obj.piece, obj.row, obj.col);
            }
        });
        /*
        game.stdout.on('data', (data) => {
            //obj = JSON.parse(data)
            console.log(data.toString())
        });*/
        socket.on('kill', () => {
            game.kill('SIGINT')
        });
    });
	socket.on('disconnect', () => {
        delete sockets[socket.id];
	});
});

process.stdin.on('data', (buf) => {
	for (id in sockets) {
        sockets[id].emit('message', String(buf));
	}
});

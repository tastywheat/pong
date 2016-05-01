var ws;
function open() {
    
    if (!("WebSocket" in window)) {  
        alert("This browser does not support WebSockets");  
        return;  
    }  
    /* @todo: Change to your own server IP address */  
    ws = new WebSocket("ws://localhost:4009/ws");  
    ws.onopen = function() {  
        console.log('Connected');
        interval = setInterval(function () {
            ws.send('ping');
        }, 60000);  
    };  
    ws.onmessage = function (evt)  
    {  
        var received_msg = evt.data;  
        console.log("Received: " + received_msg);
        var data = JSON.parse(received_msg);
        tweenTo(data.x, data.y);
    };  
    ws.onclose = function()  
    {  
        console.log('Connection closed');
        clearInterval(interval)  
    };  
}      


var opts = {
    width: 640,
    height: 480,
    dashSize: 5,
    ballVelocity: 400,
    paddleMargin: 50,
    paddleVelocity: 500,
    segments: {
        1: [-45, -135],
        2: [-30, -150],
        3: [-15, -165],
        4: [0, 180],
        5: [0, 180],
        6: [15, 165], 
        7: [30, 150],
        8: [45, 135]
    }
};

var ball,
    paddleLeft,
    paddleLeftLastY,
    aKey,
    zKey,
    paddleRight,
    paddles;

var main = {
    preload () {
        game.load.image('ball', 'assets/ball.png');  
        game.load.image('paddle', 'assets/paddle.png');  
    },
    
    create () {
        
        ball = game.add.sprite(game.world.centerX, game.world.centerY, 'ball');
        ball.anchor.set(0.5, 0.5);
        
        aKey = game.input.keyboard.addKey(Phaser.Keyboard.A);
        zKey = game.input.keyboard.addKey(Phaser.Keyboard.Z);
        
        
        upKey = game.input.keyboard.addKey(Phaser.Keyboard.UP);
        downKey = game.input.keyboard.addKey(Phaser.Keyboard.DOWN);
        
        paddles = game.add.group();
        paddles.enableBody = true;
        paddles.physicsBodyType = Phaser.Physics.ARCADE;
        
        paddleLeft = game.add.sprite(opts.paddleMargin, opts.height/2, 'paddle');
        paddleRight = game.add.sprite(opts.width - opts.paddleMargin, opts.height/2, 'paddle');
        paddleLeft.name = 'paddle-left';
        paddleRight.name = 'paddle-right';
        
        paddles.add(paddleLeft);
        paddles.add(paddleRight);
        
        paddles.setAll('checkWorldBounds', true);
        paddles.setAll('body.collideWorldBounds', true);
        paddles.setAll('body.immovable', true);
        paddleLeft.anchor.set(0.5);
        paddleRight.anchor.set(0.5);
        
        this.drawCenterLine();
        
        game.physics.startSystem(Phaser.Physics.ARCADE);
        // game.physics.arcade.enable(ball, Phaser.Physics.ARCADE);;
        
        
        // ball.checkWorldBounds = true;
        // ball.body.collideWorldBounds = true;
        // ball.body.immovable = true;
        // ball.body.bounce.set(1);
        
        // game.time.events.add(Phaser.Timer.SECOND, this.startBall, this);
    },
    
    update () {
        
        if (ws && paddleLeftLastY !== paddleLeft.y) {
            // ws.send('paddleLeftY:' + paddleLeft.y);
            paddleLeftLastY = paddleLeft.y;
        }
        
        if (aKey.isDown) {
            paddleLeft.body.velocity.y = -opts.paddleVelocity;
        } else if (zKey.isDown) {
            paddleLeft.body.velocity.y = opts.paddleVelocity;
        } else {
            paddleLeft.body.velocity.y = 0;
        }
        
        if (upKey.isDown) {
            paddleRight.body.velocity.y = -opts.paddleVelocity;
        } else if (downKey.isDown) {
            paddleRight.body.velocity.y = opts.paddleVelocity;
        } else {
            paddleRight.body.velocity.y = 0;
        }
        
        game.physics.arcade.overlap(ball, paddles, this.checkCollision, null, this);
    },
    
    checkCollision (ball, paddle) {
        var segment = Math.floor( Math.max(0, (ball.y - paddle.y) / paddle.body.height) * 7) + 1;
        var side = paddle.name === 'paddle-left' ? 0 : 1;
        var angle = opts.segments[segment][side];
        game.physics.arcade.velocityFromAngle(angle, opts.ballVelocity, ball.body.velocity);
    },
    
    drawCenterLine () {
        var backgroundGraphics = game.add.graphics(0, 0);
        backgroundGraphics.lineStyle(2, 0xFFFFFF, 1)
        var y;
        for (y = 0; y < opts.height; y = y + opts.dashSize * 2) {
            backgroundGraphics.moveTo(game.world.centerX, y);
            backgroundGraphics.lineTo(game.world.centerX, y + opts.dashSize);
        }
    },
    
    startBall () {
        game.physics.arcade.velocityFromAngle(-30, opts.ballVelocity, ball.body.velocity);
    }
}
var t;
function tweenTo (x, y) {
    if (t) {
        t.stop();
    }
    t = game.add.tween(ball).to({x: x, y: y}, 60, undefined, true);
}

function tweenTos (x, y) {
    game.add.tween(ball).to({x: x, y: y}, 2000, undefined, true);
}

var game = new Phaser.Game(opts.width, opts.height, Phaser.AUTO, '', main);

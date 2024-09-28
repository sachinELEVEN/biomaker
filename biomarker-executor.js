const express = require('express');
const { spawn } = require('child_process');

const app = express();

app.get('/', (req, res) => {
    console.log("Received request");

    // Return a promise for running the Python script
    let runPy = new Promise((resolve, reject) => {
        const pyprog = spawn('python', ['/Users/sachinjeph/Desktop/biomarker/repo/aryn-test.py', '/Users/sachinjeph/Desktop/biomarker/repo/assets/single-page-medical-report-img.pdf']);

        let output = '';

        // Collect the data from stdout
        pyprog.stdout.on('data', (data) => {
            output += data.toString();
        });

        // Handle any errors from stderr
        pyprog.stderr.on('data', (data) => {
            console.error("Error:", data.toString());
            //idk why but this gets logged when we are making api calls to aryn servers
             //reject(data.toString());
        });

        // Resolve the promise when the process ends
        pyprog.on('close', (code) => {
            if (code === 0) {
                resolve(output); // Resolve with the output
            } else {
                reject(`Process exited with code: ${code}`); // Handle non-zero exit codes
            }
        });
    });

    // Respond to the request
    runPy.then((fromRunpy) => {
        console.log(fromRunpy);
        res.send(fromRunpy); // Send output as response
    }).catch((error) => {
        console.error("Failed to run Python script:", error);
        res.status(500).send("An error occurred while running the script.");
    });
});

app.listen(4000, () => console.log('Application listening on port 4000!'));

const express = require('express');
const bodyParser = require('body-parser');
const mongoose = require('mongoose');

const app = express();
const port = 3000;

// Connect to MongoDB
mongoose.connect('mongodb://localhost:27017/voting')
  .then(() => console.log('Connected to MongoDB'))
  .catch(error => console.error('Failed to connect to MongoDB:', error));

// Define a schema and model for Voter
const voterSchema = new mongoose.Schema({
  documentNumber: { type: String, required: true }
});

const Voters = mongoose.model('voters', voterSchema);

app.use(bodyParser.json());

app.post('/check-document', async (req, res) => {
  const documentNumber = req.body.documentNumber;
  console.log('Received document number:', documentNumber);

  try {
    const voter = await Voters.findOne({ documentNumber: documentNumber });
    if (voter) {
      console.log(`Document number ${documentNumber} found in the database.`);
      console.log('Voter:', voter); // Print the voter object
      res.json({ exists: true });
    } else {
      console.log(`Document number ${documentNumber} not found in the database.`);
      res.json({ exists: false });
    }
  } catch (error) {
    console.error('Error querying database:', error);
    res.status(500).json({ error: 'Server error. Please try again later.' });
  }
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});

const mongoose = require('mongoose');

// Connect to MongoDB
mongoose.connect('mongodb://localhost:27017/voting')
  .then(() => console.log('Connected to MongoDB'))
  .catch(error => console.error('Failed to connect to MongoDB:', error));

// Define a schema and model for Voter
const voterSchema = new mongoose.Schema({
  documentNumber: { type: String, required: true},
  firstName: { type: String, required: true },
  lastName: { type: String, required: true },
  dateOfBirth: { type: String, required: true },
  nationality: { type: String, required: true },
  dateOfExpiry: { type: String, required: true }
});

const Voter = mongoose.model('Voter', voterSchema);

// Pre-populate with eligible voters
const eligibleVoters = [
  {
    documentNumber: '1234567890',
    firstName: 'Guessoum',
    lastName: 'Abdennour',
    dateOfBirth: '1998-10-12',
    nationality: 'DZ',
    dateOfExpiry: '2030-01-01'
  },
  {
    documentNumber: '0987654321',
    firstName: 'Ahmed',
    lastName: 'Benzina',
    dateOfBirth: '1990-05-22',
    nationality: 'DZ',
    dateOfExpiry: '2035-12-31'
  },
  {
    documentNumber: '1122334455',
    firstName: 'Sarah',
    lastName: 'Boulifa',
    dateOfBirth: '1985-07-15',
    nationality: 'DZ',
    dateOfExpiry: '2025-11-15'
  }
];

async function populateDB() {
  await Voter.deleteMany({}); // Clear the collection if re-populating
  for (const voter of eligibleVoters) {
    try {
      const newVoter = new Voter(voter);
      await newVoter.save();
      console.log(`Voter ${voter.documentNumber} added to the database.`);
    } catch (error) {
      console.error(`Failed to add voter ${voter.documentNumber}:`, error.message);
    }
  }
  mongoose.connection.close();
}

populateDB();









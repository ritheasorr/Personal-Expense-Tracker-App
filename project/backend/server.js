const express = require('express');
const bodyParser = require('body-parser');
const userRoutes = require('./routes/userRoutes');
const authRoutes = require('./routes/authRoutes');
const expenseRoutes = require("./routes/expenseRoutes"); // Import your expense routes
const verifyToken = require('./middleware/verifyToken'); // Import your middleware

const dotenv = require('dotenv');

dotenv.config();
const app = express();
app.use(bodyParser.json());

// Auth and user routes
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);

// Apply verifyToken middleware to /expenses routes
app.use('/expenses', verifyToken, expenseRoutes);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));

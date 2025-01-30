const bcrypt = require('bcryptjs');
const db = require('../config/db');

const jwt = require('jsonwebtoken');

exports.register = (req, res) => {
    const { username, email, hashed_pass } = req.body;

    // Validate input
    if (!username || !email || !hashed_pass) {
        return res.status(400).json({ message: 'All fields are required.' });
    }

    // Hash the password
    const hashedPassword = bcrypt.hashSync(hashed_pass, 10);

    // Insert the user into the database
    const query = `INSERT INTO users (username, email, hashed_pass) VALUES (?, ?, ?)`;
    db.run(query, [username, email, hashedPassword], function (err) {
        if (err) {
            if (err.message.includes('UNIQUE constraint failed')) {
                return res.status(400).json({ message: 'Username or email already exists.' });
            }
            return res.status(500).json({ message: 'Database error.', error: err.message });
        }
        res.status(201).json({ message: 'User registered successfully.' });
    });
};

exports.login = (req, res) => {
    const { email, password } = req.body;

    if (!email || !password) {
        return res.status(400).json({ message: 'Email and password are required.' });
    }

    const query = `
        SELECT id AS id, 
               username AS username, 
               email AS email, 
               hashed_pass AS hashed_pass 
        FROM users 
        WHERE email = ?
    `;
    db.get(query, [email], (err, user) => {
        if (err) {
            return res.status(500).json({ message: 'Database error.', error: err.message });
        }
        if (!user) {
            return res.status(404).json({ message: 'User not found.' });
        }
        const isPasswordValid = bcrypt.compareSync(password, user.hashed_pass);
        if (!isPasswordValid) {
            return res.status(401).json({ message: 'Invalid password.' });
        }

        const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET, { expiresIn: '1h' });
        res.status(200).json({ message: 'Login successful.', token });

        console.log("User ID:", user.id);
        console.log("Generated Token:", token);

    });
};


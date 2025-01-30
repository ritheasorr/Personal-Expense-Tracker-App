const jwt = require('jsonwebtoken');

exports.protect = (req, res, next) => {
    const token = req.headers.authorization?.split(' ')[1];
    if (!token) return res.status(401).json({ message: 'No token provided.' });

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.userId = decoded.sub; // Attach the user ID to the request object
        next();
    } catch (err) {
        res.status(401).json({ message: 'Invalid or expired token.' });
    }
};



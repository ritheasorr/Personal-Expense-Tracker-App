const jwt = require('jsonwebtoken');

const verifyToken = (req, res, next) => {
    const token = req.headers['authorization'];
    if (!token) {
        return res.status(403).json({ error: "No token provided." });
    }

    const tokenWithoutBearer = token.split(' ')[1]; // Extract the token
    jwt.verify(tokenWithoutBearer, process.env.JWT_SECRET, (err, decoded) => {
        if (err) {
            return res.status(403).json({ error: "Failed to authenticate token." });
        }
        req.userId = decoded.id; // Assign the user ID from the token
        console.log("Verified User ID:", req.userId); // Add log for debugging
        next();
    });
};


module.exports = verifyToken; // Ensure this is properly exported

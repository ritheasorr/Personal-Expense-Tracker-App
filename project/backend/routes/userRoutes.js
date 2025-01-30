const express = require('express');
const { getUsers, addUser } = require('../controllers/userController');
const router = express.Router();

router.get('/', getUsers); // GET all users
router.post('/', addUser); // Add a new user

module.exports = router;

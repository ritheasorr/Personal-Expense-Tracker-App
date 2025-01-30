const express = require('express');
const router = express.Router();
const expenseController = require('../controllers/expenseController');


// Apply 'protect' middleware to secure routes that require authentication
router.post('/', expenseController.addExpense);
router.get('/',expenseController.getExpensesByUser);
router.get("/amountByCategory", expenseController.getAmountByCategory);
router.get('/:id',expenseController.getExpenseById);
router.put('/:id',expenseController.updateExpense);
router.delete('/:id',expenseController.deleteExpense);

module.exports = router;

const db = require("../config/db");

// Add a new expense
const addExpense = (req, res) => {
  console.log("Request body:", req.body); // Log the incoming request body
  console.log("User ID from token:", req.userId); // Log the extracted user ID

  const { amount, category, date, note } = req.body;
  const userId = req.userId;

  if (!amount || !category || !date || !userId) {
      return res.status(400).json({ error: "Amount, category, date, and userId are required." });
  }

  const query = `
      INSERT INTO expense (user_id, amount, category, date, notes)
      VALUES (?, ?, ?, ?, ?)
  `;

  db.run(query, [userId, amount, category, date, note], function (err) {
      if (err) {
          console.error("Database Error:", err.message);
          return res.status(500).json({ error: "Failed to add expense. Details: " + err.message });
      }
      res.status(201).json({
          message: "Expense added successfully.",
          expense: {
              id: this.lastID,
              userId,
              amount,
              category,
              date,
              note,
          },
      });
  });
};

const getExpensesByUser = (req, res) => {
  const { userId } = req.query; // Ensure userId is passed as a query parameter

  if (!userId) {
    return res.status(400).json({ error: "User ID is required." });
  }

  const query = `SELECT category FROM expense WHERE user_id = ?`;
  db.all(query, [userId], (err, rows) => {
    if (err) {
      return res.status(500).json({ error: "Failed to retrieve expenses." });
    }
    res.status(200).json({ expenses: rows });
  });
};

const getAmountByCategory = (req, res) => {
  const { userId } = req.query;

  if (!userId) {
    return res.status(400).json({ error: "User ID is required." });
  }

  const query = `SELECT category, SUM(amount) as total FROM expense WHERE user_id = ? GROUP BY category`;

  db.all(query, [userId], (err, rows) => {
    if (err) {
      return res.status(500).json({ error: `Database error: ${err.message}` });
    }
    
    if (rows.length === 0) {
      return res.status(404).json({ message: "No expense data found for this user." });
    }

    res.status(200).json({ expenses: rows });
  });
};


// Retrieve a single expense by ID
const getExpenseById = (req, res) => {
  const { id } = req.params;

  const query = `SELECT * FROM expenses WHERE id = ?`;
  db.get(query, [id], (err, row) => {
    if (err) {
      return res.status(500).json({ error: "Failed to retrieve expense." });
    }
    if (!row) {
      return res.status(404).json({ error: "Expense not found." });
    }
    res.status(200).json({ expense: row });
  });
};

// Update an existing expense
const updateExpense = (req, res) => {
  const { id } = req.params;
  const { amount, category, date, note } = req.body;

  const query = `
    UPDATE expenses
    SET amount = ?, category = ?, date = ?, note = ?
    WHERE id = ?
  `;

  db.run(query, [amount, category, date, note, id], function (err) {
    if (err) {
      return res.status(500).json({ error: "Failed to update expense." });
    }
    if (this.changes === 0) {
      return res.status(404).json({ error: "Expense not found." });
    }
    res.status(200).json({ message: "Expense updated successfully." });
  });
};

// Delete an expense
const deleteExpense = (req, res) => {
  const { id } = req.params;

  const query = `DELETE FROM expenses WHERE id = ?`;
  db.run(query, [id], function (err) {
    if (err) {
      return res.status(500).json({ error: "Failed to delete expense." });
    }
    if (this.changes === 0) {
      return res.status(404).json({ error: "Expense not found." });
    }
    res.status(200).json({ message: "Expense deleted successfully." });
  });
};

module.exports = {
  addExpense,
  getExpensesByUser,
  getExpenseById,
  getAmountByCategory,
  updateExpense,
  deleteExpense,
};

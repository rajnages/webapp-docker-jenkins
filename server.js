// server.js
const express = require('express');
const app = express();
const PORT = 3000;

// Middleware to parse request bodies
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve static files (like CSS and HTML) from the 'public' folder
app.use(express.static('public'));

let tasks = [];

// Get all tasks
app.get('/tasks', (req, res) => {
   res.json(tasks);
});

// Add a new task
app.post('/tasks', (req, res) => {
   const task = req.body.task;
   if (task) {
      tasks.push({ id: Date.now(), task });
      res.status(201).json({ message: 'Task added successfully' });
   } else {
      res.status(400).json({ message: 'Task content is required' });
   }
});

// Delete a task by ID
app.delete('/tasks/:id', (req, res) => {
   const id = parseInt(req.params.id, 10);
   tasks = tasks.filter((task) => task.id !== id);
   res.json({ message: 'Task deleted successfully' });
});

app.listen(PORT, () => {
   console.log(`Server running at http://localhost:${PORT}`);
});

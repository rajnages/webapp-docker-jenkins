const taskList = document.getElementById('taskList');
const taskInput = document.getElementById('taskInput');
const progressCircle = document.getElementById('progressCircle');
const progressText = document.getElementById('progressText');
const modal = document.getElementById('taskModal');

let tasks = [];

function openModal() {
   modal.style.display = 'flex';
}

function closeModal() {
   modal.style.display = 'none';
}

function addTask() {
   const taskText = taskInput.value.trim();
   if (taskText) {
      tasks.push({ text: taskText, completed: false });
      taskInput.value = '';
      closeModal();
      updateTaskList();
      updateProgress();
   }
}

function updateTaskList() {
   taskList.innerHTML = '';
   tasks.forEach((task, index) => {
      const li = document.createElement('li');
      li.className = task.completed ? 'completed' : '';
      li.innerHTML = `
         <span onclick="toggleTask(${index})">${task.text}</span>
         <button class="complete-button" onclick="toggleTask(${index})">Complete</button>
         <button onclick="deleteTask(${index})">Delete</button>`;
      taskList.appendChild(li);
   });
}

function toggleTask(index) {
   tasks[index].completed = !tasks[index].completed;
   updateTaskList();
   updateProgress();
}

function deleteTask(index) {
   tasks.splice(index, 1);
   updateTaskList();
   updateProgress();
}

function updateProgress() {
   const completedTasks = tasks.filter(task => task.completed).length;
   const progress = (completedTasks / tasks.length) * 100 || 0;
   progressCircle.style.background = `conic-gradient(#4CAF50 ${progress}%, #ddd ${progress}%)`;
   progressText.textContent = `${Math.round(progress)}%`;
}


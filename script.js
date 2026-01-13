const navToggle = document.getElementById("navToggle");
const navLinks = document.getElementById("navLinks");

navToggle?.addEventListener("click", () => {
  const isOpen = navLinks.classList.toggle("open");
  navToggle.setAttribute("aria-expanded", String(isOpen));
});

document.getElementById("year").textContent = String(new Date().getFullYear());

// Hours display (simple + clear)
const todayHoursEl = document.getElementById("todayHours");
const day = new Date().getDay(); // 0=Sun ... 6=Sat

let todayHours = "Mon–Fri 8:15 AM – 5:00 PM";
if (day === 6) todayHours = "Saturday: 8:15 AM – 2:00 PM";
if (day === 0) todayHours = "Sunday: Closed";

todayHoursEl.textContent = todayHours;

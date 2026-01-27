// ==========================================
// SPLASH AUTO DETAIL - INTERACTIVE FEATURES
// ==========================================

// Strict mode for better error checking
'use strict';

// ==========================================
// MOBILE NAVIGATION TOGGLE
// ==========================================

const navToggle = document.getElementById('navToggle');
const navLinks = document.getElementById('navLinks');

if (navToggle && navLinks) {
  navToggle.addEventListener('click', () => {
    const isOpen = navLinks.classList.toggle('open');
    navToggle.setAttribute('aria-expanded', String(isOpen));
  });

  // Close mobile menu when a link is clicked
  navLinks.querySelectorAll('a').forEach(link => {
    link.addEventListener('click', () => {
      navLinks.classList.remove('open');
      navToggle.setAttribute('aria-expanded', 'false');
    });
  });
}

// ==========================================
// DYNAMIC YEAR IN FOOTER
// ==========================================

const yearElement = document.getElementById('year');
if (yearElement) {
  yearElement.textContent = String(new Date().getFullYear());
}

// ==========================================
// BUSINESS HOURS DISPLAY
// ==========================================

const todayHoursEl = document.getElementById('todayHours');

if (todayHoursEl) {
  const now = new Date();
  const day = now.getDay(); // 0 = Sunday, 1 = Monday, ..., 6 = Saturday
  const currentTime = now.getHours() * 60 + now.getMinutes(); // Time in minutes since midnight

  // Define business hours in minutes since midnight
  const HOURS = {
    WEEKDAY_OPEN: 8 * 60 + 15,   // 8:15 AM = 495 minutes
    WEEKDAY_CLOSE: 17 * 60,       // 5:00 PM = 1020 minutes
    SATURDAY_OPEN: 8 * 60 + 15,   // 8:15 AM = 495 minutes
    SATURDAY_CLOSE: 14 * 60       // 2:00 PM = 840 minutes
  };

  let todayHours = '';
  let isOpen = false;

  // Determine hours and open status based on day
  if (day >= 1 && day <= 5) {
    // Monday - Friday
    todayHours = '8:15 AM – 5:00 PM';
    isOpen = currentTime >= HOURS.WEEKDAY_OPEN && currentTime < HOURS.WEEKDAY_CLOSE;
  } else if (day === 6) {
    // Saturday
    todayHours = '8:15 AM – 2:00 PM';
    isOpen = currentTime >= HOURS.SATURDAY_OPEN && currentTime < HOURS.SATURDAY_CLOSE;
  } else {
    // Sunday
    todayHours = 'Closed';
    isOpen = false;
  }

  todayHoursEl.textContent = todayHours;

  // Update status badge if it exists
  const statusBadge = document.getElementById('statusBadge');
  const statusText = statusBadge?.querySelector('.status-text');

  if (statusBadge && statusText) {
    if (isOpen) {
      statusBadge.classList.remove('closed');
      statusText.textContent = 'Open Now';
    } else {
      statusBadge.classList.add('closed');
      
      // Provide helpful "opens next" message
      if (day === 0) {
        // Sunday - opens Monday
        statusText.textContent = 'Closed • Opens Monday 8:15 AM';
      } else if (day === 6 && currentTime >= HOURS.SATURDAY_CLOSE) {
        // Saturday after closing
        statusText.textContent = 'Closed • Opens Monday 8:15 AM';
      } else if (day >= 1 && day <= 5 && currentTime >= HOURS.WEEKDAY_CLOSE) {
        // Weekday after closing
        if (day === 5) {
          // Friday evening
          statusText.textContent = 'Closed • Opens Saturday 8:15 AM';
        } else {
          // Other weekday evening
          statusText.textContent = 'Closed • Opens Tomorrow 8:15 AM';
        }
      } else if (day >= 1 && day <= 5 && currentTime < HOURS.WEEKDAY_OPEN) {
        // Weekday before opening
        statusText.textContent = 'Closed • Opens Today 8:15 AM';
      } else if (day === 6 && currentTime < HOURS.SATURDAY_OPEN) {
        // Saturday before opening
        statusText.textContent = 'Closed • Opens Today 8:15 AM';
      } else {
        statusText.textContent = 'Closed';
      }
    }
  }
}

// ==========================================
// SMOOTH SCROLL ENHANCEMENT
// ==========================================

// Add smooth scroll offset for sticky header
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
  anchor.addEventListener('click', function (e) {
    const href = this.getAttribute('href');
    
    // Skip if it's just "#" or "#top"
    if (href === '#' || href === '#top') {
      e.preventDefault();
      window.scrollTo({ top: 0, behavior: 'smooth' });
      return;
    }

    const target = document.querySelector(href);
    
    if (target) {
      e.preventDefault();
      
      // Calculate offset for sticky header
      const headerHeight = document.querySelector('.site-header')?.offsetHeight || 0;
      const targetPosition = target.offsetTop - headerHeight - 20;
      
      window.scrollTo({
        top: targetPosition,
        behavior: 'smooth'
      });
    }
  });
});

// ==========================================
// ANALYTICS HELPERS (Optional)
// ==========================================

// Track phone number clicks
document.querySelectorAll('a[href^="tel:"]').forEach(link => {
  link.addEventListener('click', () => {
    console.log('Phone call initiated:', link.href);
    // Add your analytics tracking here if needed
    // Example: gtag('event', 'phone_call', { method: 'click' });
  });
});

// Track direction clicks
document.querySelectorAll('a[href*="google.com/maps"]').forEach(link => {
  link.addEventListener('click', () => {
    console.log('Directions requested');
    // Add your analytics tracking here if needed
    // Example: gtag('event', 'get_directions', { method: 'click' });
  });
});

// ==========================================
// PERFORMANCE OPTIMIZATION
// ==========================================

// Lazy load map iframe when it comes into view
const mapIframe = document.querySelector('.map-wrap iframe');

if (mapIframe && 'IntersectionObserver' in window) {
  const mapObserver = new IntersectionObserver((entries, observer) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        const iframe = entry.target;
        if (iframe.dataset.src) {
          iframe.src = iframe.dataset.src;
          observer.unobserve(iframe);
        }
      }
    });
  }, {
    rootMargin: '50px'
  });

  // Only observe if the iframe has a data-src attribute
  if (mapIframe.hasAttribute('data-src')) {
    mapObserver.observe(mapIframe);
  }
}

// ==========================================
// GALLERY FUNCTIONALITY
// ==========================================

function initGallery() {
  const filterButtons = document.querySelectorAll('.filter-btn');
  const galleryItems = document.querySelectorAll('.gallery-item');

  if (!filterButtons.length || !galleryItems.length) return;

  // Filter gallery items
  filterButtons.forEach((button) => {
    button.addEventListener('click', () => {
      const filter = button.dataset.filter;

      // Update active button
      filterButtons.forEach((btn) => btn.classList.remove('active'));
      button.classList.add('active');

      // Filter items
      galleryItems.forEach((item) => {
        if (filter === 'all' || item.dataset.category === filter) {
          item.classList.remove('hidden');
        } else {
          item.classList.add('hidden');
        }
      });
    });
  });

  // Lightbox functionality
  const lightbox = createLightbox();

  galleryItems.forEach((item, index) => {
    item.addEventListener('click', () => {
      const img = item.querySelector('img');
      if (img && img.src) {
        openLightbox(lightbox, img.src, img.alt);
      }
    });
  });
}

function createLightbox() {
  const lightbox = document.createElement('div');
  lightbox.className = 'lightbox';
  lightbox.innerHTML = `
    <button class="lightbox-close" aria-label="Close lightbox">&times;</button>
    <button class="lightbox-nav lightbox-prev" aria-label="Previous image">&lsaquo;</button>
    <div class="lightbox-content">
      <img src="" alt="" />
    </div>
    <button class="lightbox-nav lightbox-next" aria-label="Next image">&rsaquo;</button>
  `;
  document.body.appendChild(lightbox);

  const closeBtn = lightbox.querySelector('.lightbox-close');
  const prevBtn = lightbox.querySelector('.lightbox-prev');
  const nextBtn = lightbox.querySelector('.lightbox-next');

  closeBtn.addEventListener('click', () => closeLightbox(lightbox));
  lightbox.addEventListener('click', (e) => {
    if (e.target === lightbox) closeLightbox(lightbox);
  });

  // Keyboard navigation
  document.addEventListener('keydown', (e) => {
    if (!lightbox.classList.contains('active')) return;

    if (e.key === 'Escape') closeLightbox(lightbox);
    if (e.key === 'ArrowLeft') navigateLightbox(-1, lightbox);
    if (e.key === 'ArrowRight') navigateLightbox(1, lightbox);
  });

  prevBtn.addEventListener('click', () => navigateLightbox(-1, lightbox));
  nextBtn.addEventListener('click', () => navigateLightbox(1, lightbox));

  return lightbox;
}

let currentImageIndex = 0;

function openLightbox(lightbox, src, alt) {
  const img = lightbox.querySelector('.lightbox-content img');
  img.src = src;
  img.alt = alt || 'Gallery image';

  // Get current visible images
  const visibleImages = Array.from(
    document.querySelectorAll('.gallery-item:not(.hidden) img')
  );
  currentImageIndex = visibleImages.findIndex(item => item.src === src);

  lightbox.classList.add('active');
  document.body.style.overflow = 'hidden';
}

function closeLightbox(lightbox) {
  lightbox.classList.remove('active');
  document.body.style.overflow = '';
}

function navigateLightbox(direction, lightbox) {
  const visibleImages = Array.from(
    document.querySelectorAll('.gallery-item:not(.hidden) img')
  );

  if (visibleImages.length === 0) return;

  currentImageIndex += direction;

  if (currentImageIndex < 0) {
    currentImageIndex = visibleImages.length - 1;
  } else if (currentImageIndex >= visibleImages.length) {
    currentImageIndex = 0;
  }

  const img = lightbox.querySelector('.lightbox-content img');
  const targetImg = visibleImages[currentImageIndex];
  img.src = targetImg.src;
  img.alt = targetImg.alt || 'Gallery image';
}

// Initialize gallery on page load
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initGallery);
} else {
  initGallery();
}

// ==========================================
// ACCESSIBILITY ENHANCEMENTS
// ==========================================

// Trap focus in mobile menu when open
if (navToggle && navLinks) {
  navToggle.addEventListener('click', () => {
    if (navLinks.classList.contains('open')) {
      // Focus first link when menu opens
      const firstLink = navLinks.querySelector('a');
      if (firstLink) {
        setTimeout(() => firstLink.focus(), 100);
      }
    }
  });

  // Close menu on Escape key
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && navLinks.classList.contains('open')) {
      navLinks.classList.remove('open');
      navToggle.setAttribute('aria-expanded', 'false');
      navToggle.focus();
    }
  });
}

// ==========================================
// INITIALIZATION LOG
// ==========================================

console.log('Splash Auto Detail website loaded successfully');

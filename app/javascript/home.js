
// Effet de scroll sur le header
window.addEventListener('scroll', function () {
    const header = document.querySelector('.magjury-header');
    if (window.scrollY > 50) {
        header.classList.add('scrolled');
    } else {
        header.classList.remove('scrolled');
    }
});

// Dropdown mobile
document.querySelectorAll('.magjury-canvas-dropdown__toggle').forEach(btn => {
    btn.addEventListener('click', () => {
        const expanded = btn.getAttribute('aria-expanded') === 'true';
        btn.setAttribute('aria-expanded', !expanded);
        btn.nextElementSibling.classList.toggle('open');
    });
});

// Recherche
const searchToggle = document.querySelector('.magjury-search__toggle');
const searchPanel = document.querySelector('.magjury-search__panel');
const search = document.querySelector('.magjury-search');

if (searchToggle && search) {
    searchToggle.addEventListener('click', () => {
        search.classList.toggle('active');
    });

    // Fermeture de la recherche en cliquant à l'extérieur
    document.addEventListener('click', (e) => {
        if (!search.contains(e.target)) {
            search.classList.remove('active');
        }
    });
}

// Off-canvas ouvrir/fermer
const burger = document.querySelector('.magjury-burger');
const canvas = document.querySelector('.magjury-canvas');
const overlay = document.querySelector('.magjury-canvas__overlay');
const closeBtn = document.querySelector('.magjury-canvas__close');

if (burger && canvas && overlay && closeBtn) {
    function openCanvas() {
        canvas.classList.add('active');
        overlay.classList.add('active');
        burger.classList.add('active');
        document.body.style.overflow = 'hidden';
    }

    function closeCanvas() {
        canvas.classList.remove('active');
        overlay.classList.remove('active');
        burger.classList.remove('active');
        document.body.style.overflow = '';
        // Fermer tous les dropdowns ouverts
        document.querySelectorAll('.magjury-canvas-dropdown__menu').forEach(menu => {
            menu.classList.remove('open');
        });
        document.querySelectorAll('.magjury-canvas-dropdown__toggle').forEach(btn => {
            btn.setAttribute('aria-expanded', 'false');
        });
    }

    burger.addEventListener('click', () => {
        canvas.classList.contains('active') ? closeCanvas() : openCanvas();
    });

    closeBtn.addEventListener('click', closeCanvas);
    overlay.addEventListener('click', closeCanvas);

    // Fermeture automatique en desktop
    window.addEventListener('resize', () => {
        if (window.innerWidth > 900) closeCanvas();
    });

    // Observer les éléments du canvas lorsqu'il s'ouvre
    canvas.addEventListener('transitionend', () => {
        if (canvas.classList.contains('active')) {
            document.querySelectorAll('#magjury-canvas-list > li').forEach((item, index) => {
                item.style.opacity = '1';
                //item.style.transform = 'translateY(20px)';
                item.style.transition = `opacity 0.4s ease ${index * 0.1}s, transform 0.4s ease ${index * 0.1}s`;
                observer.observe(item);
            });
        }
    });
}





// Fonction pour animer les compteurs
function animateCounters() {
    const counters = document.querySelectorAll('.count-text');

    counters.forEach(counter => {
        const target = parseInt(counter.getAttribute('data-stop'));
        const speed = parseInt(counter.getAttribute('data-speed'));
        const countText = counter;

        let current = 0;
        const increment = target / (speed / 50); // 50ms par intervalle

        const updateCount = () => {
            current += increment;

            if (current < target) {
                countText.textContent = Math.floor(current);
                setTimeout(updateCount, 50);
            } else {
                countText.textContent = target;
            }
        };

        updateCount();
    });
}

// Observer pour déclencher l'animation quand les éléments sont visibles
function setupCounterObserver() {
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                animateCounters();
                observer.unobserve(entry.target); // Arrêter d'observer après déclenchement
            }
        });
    }, {
        threshold: 0.5 // Déclencher quand 50% de l'élément est visible
    });

    const counterSection = document.querySelector('.fact-counter');
    if (counterSection) {
        observer.observe(counterSection);
    }
}

// Version alternative avec délai fixe (si IntersectionObserver n'est pas supporté)
function setupCountersWithTimeout() {
    setTimeout(() => {
        animateCounters();
    }, 1000); // Démarrer après 1 seconde
}

// Initialisation au chargement de la page
document.addEventListener('DOMContentLoaded', function () {
    // Utiliser IntersectionObserver si supporté, sinon utiliser timeout
    if ('IntersectionObserver' in window) {
        setupCounterObserver();
    } else {
        setupCountersWithTimeout();
    }
});

// Réinitialiser les compteurs si besoin (optionnel)
function resetCounters() {
    const counters = document.querySelectorAll('.count-text');
    counters.forEach(counter => {
        counter.textContent = '0';
    });
}





class TeamSlider {
    constructor() {
        this.sliderContainer = document.getElementById('sliderContainer');
        this.sliderTrack = document.getElementById('sliderTrack');
        if (!this.sliderTrack) return;

        this.sliderDots = document.getElementById('sliderDots');
        this.progressBar = document.getElementById('progressBar');
        this.prevBtn = document.querySelector('.slider-arrow.prev');
        this.nextBtn = document.querySelector('.slider-arrow.next');

        this.cards = Array.from(this.sliderTrack.querySelectorAll('.team-card'));
        this.currentIndex = 0;
        this.cardWidth = 0;
        this.cardsPerView = this.getCardsPerView();
        this.totalCards = this.cards.length;
        this.autoSlideInterval = null;
        this.progressInterval = null;
        this.isTransitioning = false;
        this.isMobile = window.innerWidth < 768;

        this.init();
    }

    init() {
        this.calculateCardWidth();
        this.createDots();
        this.updateSlider();
        this.setupEventListeners();

        if (!this.isMobile) {
            this.startAutoSlide();
        }

        window.addEventListener('resize', () => {
            this.isMobile = window.innerWidth < 768;
            this.calculateCardWidth();
            this.createDots();
            this.updateSlider();

            if (!this.isMobile && !this.autoSlideInterval) {
                this.startAutoSlide();
            } else if (this.isMobile && this.autoSlideInterval) {
                this.stopAutoSlide();
            }
        });
    }

    getCardsPerView() {
        if (window.innerWidth < 768) return 1;
        if (window.innerWidth < 1024) return 2;
        return 3;
    }

    calculateCardWidth() {
        this.cardsPerView = this.getCardsPerView();
        if (this.cards.length > 0) {
            const cardStyle = window.getComputedStyle(this.cards[0]);
            const cardWidth = this.cards[0].offsetWidth;
            const gap = parseInt(window.getComputedStyle(this.sliderTrack).gap) || 0;
            this.cardWidth = cardWidth + gap;
        }
    }

    createDots() {
        const totalSlides = Math.ceil(this.totalCards / this.cardsPerView);
        this.sliderDots.innerHTML = '';

        for (let i = 0; i < totalSlides; i++) {
            const dot = document.createElement('button');
            dot.className = `slider-dot ${i === 0 ? 'active' : ''}`;
            dot.setAttribute('aria-label', `Aller au slide ${i + 1}`);
            dot.addEventListener('click', () => this.goToSlide(i));
            this.sliderDots.appendChild(dot);
        }
    }

    updateSlider() {
        if (this.isMobile) {
            // Sur mobile, on utilise le scroll natif
            return;
        }

        const translateX = -this.currentIndex * this.cardWidth;
        this.sliderTrack.style.transform = `translateX(${translateX}px)`;

        // Mettre à jour les dots
        const dots = this.sliderDots.querySelectorAll('.slider-dot');
        const activeDotIndex = Math.floor(this.currentIndex / this.cardsPerView);
        dots.forEach((dot, index) => {
            dot.classList.toggle('active', index === activeDotIndex);
        });

        this.resetProgressBar();
    }

    nextSlide() {
        if (this.isTransitioning) return;

        this.isTransitioning = true;
        const maxIndex = this.totalCards - this.cardsPerView;

        if (this.currentIndex >= maxIndex) {
            // Retour au début avec effet de boucle
            this.currentIndex = 0;
        } else {
            this.currentIndex += this.cardsPerView;
        }

        this.updateSlider();

        setTimeout(() => {
            this.isTransitioning = false;
        }, 600);
    }

    prevSlide() {
        if (this.isTransitioning) return;

        this.isTransitioning = true;

        if (this.currentIndex <= 0) {
            // Aller à la fin avec effet de boucle
            this.currentIndex = Math.floor((this.totalCards - 1) / this.cardsPerView) * this.cardsPerView;
        } else {
            this.currentIndex -= this.cardsPerView;
        }

        this.updateSlider();

        setTimeout(() => {
            this.isTransitioning = false;
        }, 600);
    }

    goToSlide(slideIndex) {
        if (this.isTransitioning) return;

        this.isTransitioning = true;
        this.currentIndex = slideIndex * this.cardsPerView;
        this.updateSlider();

        setTimeout(() => {
            this.isTransitioning = false;
        }, 600);
    }

    setupEventListeners() {
        this.prevBtn.addEventListener('click', () => {
            if (!this.isMobile) this.stopAutoSlide();
            this.prevSlide();
            if (!this.isMobile) this.startAutoSlide();
        });

        this.nextBtn.addEventListener('click', () => {
            if (!this.isMobile) this.stopAutoSlide();
            this.nextSlide();
            if (!this.isMobile) this.startAutoSlide();
        });

        // Pause auto-slide au survol (desktop seulement)
        if (!this.isMobile) {
            this.sliderTrack.addEventListener('mouseenter', () => this.stopAutoSlide());
            this.sliderTrack.addEventListener('mouseleave', () => this.startAutoSlide());
        }

        // Support du clavier
        document.addEventListener('keydown', (e) => {
            if (e.key === 'ArrowLeft') {
                this.stopAutoSlide();
                this.prevSlide();
                this.startAutoSlide();
            } else if (e.key === 'ArrowRight') {
                this.stopAutoSlide();
                this.nextSlide();
                this.startAutoSlide();
            }
        });
    }

    startAutoSlide() {
        if (this.isMobile) return;

        this.stopAutoSlide();
        this.autoSlideInterval = setInterval(() => {
            this.nextSlide();
        }, 5000);

        this.startProgressBar();
    }

    stopAutoSlide() {
        if (this.autoSlideInterval) {
            clearInterval(this.autoSlideInterval);
            this.autoSlideInterval = null;
        }
        if (this.progressInterval) {
            clearInterval(this.progressInterval);
            this.progressInterval = null;
        }
        this.progressBar.style.width = '0%';
    }

    startProgressBar() {
        if (this.isMobile) return;

        this.progressBar.style.width = '0%';
        let width = 0;

        this.progressInterval = setInterval(() => {
            if (width >= 100) {
                width = 0;
            } else {
                width += 0.5;
                this.progressBar.style.width = width + '%';
            }
        }, 25);
    }

    resetProgressBar() {
        if (this.isMobile) return;
        this.stopAutoSlide();
        this.startAutoSlide();
    }

    // Méthode pour rafraîchir le slider quand de nouvelles cartes sont ajoutées
    refresh() {
        this.cards = Array.from(this.sliderTrack.querySelectorAll('.team-card'));
        this.totalCards = this.cards.length;
        this.calculateCardWidth();
        this.createDots();
        this.updateSlider();
    }
}

// Initialisation du slider
document.addEventListener('DOMContentLoaded', () => {
    const slider = new TeamSlider();

    // Exposer le slider globalement pour pouvoir le rafraîchir
    window.teamSlider = slider;
});


// Gestion de la vidéo de fond
document.addEventListener('DOMContentLoaded', function () {
    const video = document.querySelector('.banner-video');

    if (video) {
        // Essayer de jouer la vidéo (nécessaire pour certains navigateurs mobiles)
        video.play().catch(error => {
            console.log("La lecture automatique de la vidéo a été bloquée:", error);
        });
    }

    // Animation du scroll
    const scrollBtn = document.querySelector('.banner-scroll');
    if (scrollBtn) {
        scrollBtn.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    }
});

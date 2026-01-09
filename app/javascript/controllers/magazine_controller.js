// app/javascript/controllers/magazine_slider_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["carousel"]

  connect() {
    this.setupCarouselAnimations()
  }

  setupCarouselAnimations() {
    const carousel = this.carouselTarget
    if (!carousel) return

    carousel.addEventListener('slide.bs.carousel', (event) => {
      // Animation d'entrée pour le slide suivant
      const nextSlide = event.relatedTarget
      this.animateSlideIn(nextSlide)
    })

    carousel.addEventListener('slid.bs.carousel', (event) => {
      // Animation de sortie pour le slide précédent
      const activeSlide = event.relatedTarget
      this.animateContent(activeSlide)
    })
  }

  animateSlideIn(slide) {
    slide.style.opacity = '0'
    slide.style.transform = 'translateX(50px)'
    
    setTimeout(() => {
      slide.style.transition = 'all 0.6s ease'
      slide.style.opacity = '1'
      slide.style.transform = 'translateX(0)'
    }, 50)
  }

  animateContent(slide) {
    const content = slide.querySelector('.magazine-slider-content')
    if (!content) return

    content.style.opacity = '0'
    content.style.transform = 'translateY(30px)'
    
    setTimeout(() => {
      content.style.transition = 'all 0.8s ease'
      content.style.opacity = '1'
      content.style.transform = 'translateY(0)'
    }, 300)
  }
}
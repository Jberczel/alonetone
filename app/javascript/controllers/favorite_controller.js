import HeartController from './heart_controller'

export default class extends HeartController {
  static values = {
    id: Number,
  }

  isFavorited() {
    return window.userFavorites.includes(this.idValue)
  }

  update(e) {
    this.dispatch('broadcast', { detail: { id: this.idValue }, target: window })
  }

  toggle(e) {
    if (this.idValue === e.detail.id)
      super.toggle()
  }
}

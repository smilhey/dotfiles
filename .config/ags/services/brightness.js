class Brightness extends Service {
    static {
        Service.register(
            this,
            {
                'screen-changed': ['float'],
            },
            {
                'screen': ['float', 'rw'],
            },
        );
    }
    #screen = Number(Utils.execAsync("light -G")) / 100;
    get screen() {
        return this.#screen;
    }
    set screen(percent) {
        if (percent < 0)
            percent = 0;
        if (percent > 1)
            percent = 1;
        Utils.execAsync(`light -S ${percent * 100}% -q`)
            .then(() => {
                this.#screen = percent;
                this.changed("screen");
            })
            .catch(print);
    }


    #onChange() {
        this.#screen = Number(Utils.exec("light -G")) / 100;
        this.changed('screen');
        this.emit('screen-changed', this.#screen);
    }
    constructor() {
        super();
        this.#onChange();
    }
}

export default new Brightness();

class GrimpanMenuBtn {
  name?: string;
  type?: string;
  onClick?: () => void;
  onChange?: () => void;
  active?: boolean;
  value?: string | number;

  constructor(
    name?: string,
    type?: string,
    onClick?: () => void,
    onChange?: () => void,
    active?: boolean,
    value?: string | number
  ) {
    this.name = name;
    this.type = type;
    this.onClick = onClick;
    this.onChange = onChange;
    this.active = active;
    this.value = value;
  }
}

interface GrimpanMenuBtnBuilder {
  setName(name: string): this;
  setType(type: string): this;
  setOnClick(onClick: () => void): this;
  setOnchange(onChange: () => void): this;
  setActive(active: boolean): this;
  setValue(value: string | number): this;
  build(): GrimpanMenuBtn;
}

class ChromeGrimpanMenuBtnBuilder implements GrimpanMenuBtnBuilder {
  btn: GrimpanMenuBtn;
  constructor() {
    this.btn = new GrimpanMenuBtn();
  }
  setName(name: string): this {
    this.btn.name = name;
    return this;
  }

  setType(type: string): this {
    this.btn.type = type;
    return this;
  }
  setOnchange(onChange: () => void): this {
    this.btn.onChange = onChange;
    return this;
  }
  setOnClick(onClick: () => void): this {
    this.btn.onClick = onClick;
    return this;
  }

  setActive(active: boolean): this {
    this.btn.active = active;
    return this;
  }

  setValue(value: string | number): this {
    this.btn.value = value;
    return this;
  }

  build(): GrimpanMenuBtn {
    return this.btn;
  }
}

class GrimpanMenuBtnDirector {
  static createBackBtn(builder: GrimpanMenuBtnBuilder) {
    const backBtnBuilder = builder
      .setName("뒤로")
      .setType("back")
      .setOnClick(() => {})
      .setActive(false);
    return backBtnBuilder;
  }
  static createForwardBtn(builder: GrimpanMenuBtnBuilder) {
    const forwardBtnBuilder = builder
      .setName("앞으로")
      .setType("forward")
      .setOnClick(() => {})
      .setActive(false);
    return forwardBtnBuilder;
  }
}

GrimpanMenuBtnDirector.createBackBtn(new ChromeGrimpanMenuBtnBuilder()).build();
GrimpanMenuBtnDirector.createForwardBtn(
  new ChromeGrimpanMenuBtnBuilder()
).build();

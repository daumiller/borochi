import { Component, h, createRef } from "/script/preact.js";
import htm from "/script/htm.js";

const html = htm.bind(h);

class WidgetContainer extends Component {
        constructor(widgetClass, widgetData) {
            super();
            const widgetInstance = new window.widgetClasses[widgetClass](widgetData);
            this.state = { class:widgetInstance, instance:widgetInstance };
        }
}

class Button extends Component {
    constructor(serializedData) {
        super();
        this.state = this.deserialize(serializedData || {});
    }

    deserialize(serializedData) {
        const data = JSON.parse(serializedData);
        const defaults = [ "name", "width", "height", "text", "icon" ];
        for(let idx=0; idx<defaults.length; ++idx) {
            if(!data.hasOwnProperty(defaults[idx])) {
                data[defaults[idx]] = Button.defaults[defaults[idx]];
            }
        }
    }
}

Button.defaults = {
    name: "button",
    width: 128,
    height: 32,
    text: "Button",
    icon: null,
};

class Application extends Component {
    outterRef = createRef();

    constructor() {
        super();
        this.state = { name:"Shiny", error:null };
    }

    //componentWillMount() {}
    //componentDidMount() {}
    //componentWillUnmount() {}
    //shouldComponentUpdate(nextProps, nextState) { return true; }
    //getSnapshotBeforeUpdate(prevProps, prevState) {}
    componentDidUpdate(prevProps, prevState, snapshot) {
        if(this.outterRef.current) {
            this.outterRef.current.setAttribute("fill", "black");
        }
    }

    componentDidCatch(error) {
        console.log(`Application Error: ${error}`);
        this.setState({ error:error });
    }

    clicked(event) {
        this.setState(function(prevState) { return { innerColor:"green" }; });
    }

    render(props, state) {
        return html`
            <div>
                <h1>${state.name} :: Preact Application Root</h1>
                <button class="ares button" onClick=${this.clicked.bind(this)}>btn01</button> <br/>
                <button class="hades button">btn02</button> <br/>
                <button class="hades button svg">
                    <svg width="24px" height="24px" viewBox="0 0 24 24" id="SVGRoot" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:cc="http://creativecommons.org/ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd" xmlns:svg="http://www.w3.org/2000/svg">
                    <defs id="defs2"/>
                    <g id="layer1">
                        <path d="M 12,2 C 17.511,2 22,6.489 22,12 22,17.511 17.511,22 12,22 6.489,22 2,17.511 2,12 2,6.489 6.489,2 12,2 Z m 0,2 c -4.43012,0 -8,3.56988 -8,8 0,4.43012 3.56988,8 8,8 4.43012,0 8,-3.56988 8,-8 0,-4.43012 -3.56988,-8 -8,-8 z m 0.9707,4 a -1,1 0 0 1 0.73633,0.29297 l 2.98047,2.98047 0.0195,0.0195 a -1.0001,1.0001 0 0 1 0.01,0.01 -1,1 0 0 1 0.0469,0.0527 -1,1 0 0 1 0.0508,0.0664 -1,1 0 0 1 0.0391,0.0605 -1.0001,1.0001 0 0 1 0.0176,0.0273 -1,1 0 0 1 0.0293,0.0566 -1,1 0 0 1 0.0312,0.0723 -1.0001,1.0001 0 0 1 0.004,0.0117 -1,1 0 0 1 0.0234,0.0645 -1.0001,1.0001 0 0 1 0.008,0.0352 -1,1 0 0 1 0.01,0.041 -1.0001,1.0001 0 0 1 0.008,0.0371 -1,1 0 0 1 0.008,0.043 -1.0001,1.0001 0 0 1 0.006,0.0723 -1.0001,1.0001 0 0 1 0.002,0.0449 -1,1 0 0 1 0,0.0117 -1,1 0 0 1 -0.002,0.0293 -1.0001,1.0001 0 0 1 -0.002,0.0371 -1,1 0 0 1 -0.004,0.0508 -1.0001,1.0001 0 0 1 -0.004,0.0293 -1,1 0 0 1 -0.0137,0.0762 -1,1 0 0 1 -0.0156,0.0586 -1.0001,1.0001 0 0 1 -0.0137,0.043 -1,1 0 0 1 -0.004,0.0137 -1.0001,1.0001 0 0 1 -0.0293,0.0703 -1.0001,1.0001 0 0 1 -0.0332,0.0664 -1,1 0 0 1 -0.0137,0.0273 -1.0001,1.0001 0 0 1 -0.0293,0.0449 -1,1 0 0 1 -0.0137,0.0215 -1.0001,1.0001 0 0 1 -0.0234,0.0332 -1,1 0 0 1 -0.0176,0.0215 -1.0001,1.0001 0 0 1 -0.0469,0.0547 -1,1 0 0 1 -0.0195,0.0215 -1.0001,1.0001 0 0 1 -0.008,0.008 -1,1 0 0 1 -0.041,0.0391 l -2.95898,2.96094 a -1,1 0 0 1 -1.41406,0 -1,1 0 0 1 0,-1.41407 L 13.58594,13 H 8 A -1,1 0 0 1 7,12 -1,1 0 0 1 8,11 h 5.58594 L 12.29297,9.70703 a -1,1 0 0 1 0,-1.41406 A -1,1 0 0 1 12.9707,8 Z" id="path2488" style="color:#000000;font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;font-size:medium;line-height:normal;font-family:sans-serif;font-variant-ligatures:normal;font-variant-position:normal;font-variant-caps:normal;font-variant-numeric:normal;font-variant-alternates:normal;font-variant-east-asian:normal;font-feature-settings:normal;font-variation-settings:normal;text-indent:0;text-align:start;text-decoration:none;text-decoration-line:none;text-decoration-style:solid;text-decoration-color:#000000;letter-spacing:normal;word-spacing:normal;text-transform:none;writing-mode:lr-tb;direction:ltr;text-orientation:mixed;dominant-baseline:auto;baseline-shift:baseline;text-anchor:start;white-space:normal;shape-padding:0;shape-margin:0;inline-size:0;clip-rule:nonzero;display:inline;overflow:visible;visibility:visible;opacity:1;isolation:auto;mix-blend-mode:normal;color-interpolation:sRGB;color-interpolation-filters:linearRGB;solid-color:#000000;solid-opacity:1;vector-effect:none;fill:#000000;fill-opacity:1;fill-rule:nonzero;stroke:none;stroke-width:2;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1;color-rendering:auto;image-rendering:auto;shape-rendering:auto;text-rendering:auto;enable-background:accumulate;stop-color:#000000;stop-opacity:1"/>
                    </g></svg>
                </button>
                <br/>
                <svg version="1.1" baseProfile="full" width="240" height="240">
                    <circle ref=${this.outterRef} cx="120" cy="120" r="100" fill="red"></circle>
                    <circle cx="120" cy="120" r="80" fill="${state.innerColor || "orange"}"></circle>
                </svg>
            </div>
        `;
    }
}

export { Application };

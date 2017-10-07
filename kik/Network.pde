class Network
{
  HashMap<NeuronName, Neuron> inputNeurons = new HashMap();
  HashMap<NeuronName, Neuron> hiddenNeurons = new HashMap();
  HashMap<NeuronName, Neuron> outputNeurons = new HashMap();
  
  public float getOutput(NeuronName name)
  {
    return outputNeurons.get(name).outputLinks.get(0).impulse;
  }
  
  public void setInput(NeuronName name, float impulse)
  {
    inputNeurons.get(name).inputLinks.get(0).impulse = impulse;
  }
  
  public void resolve()
  {
    for (Neuron inputNeuron : inputNeurons.values())
    {
      inputNeuron.resolve();
    }
    for (Neuron hiddenNeuron : hiddenNeurons.values())
    {
      hiddenNeuron.resolve();
    }
    for (Neuron outputNeuron : outputNeurons.values())
    {
      outputNeuron.resolve();
    }
  }
  
  Network (NetworkPrototype prototype)
  {
    NeuronName[] inputNeuronNames, hiddenNeuronNames, outputNeuronNames;
    switch (prototype)
    {
      default:
      case FLYING_ROBOT_STRATEGY:
        inputNeuronNames = new NeuronName[] { NeuronName.HAPTIC, NeuronName.VISUAL_TYPE, NeuronName.VISUAL_POSITION, NeuronName.WEAPON, NeuronName.ENERGY };
        hiddenNeuronNames = new NeuronName[] { NeuronName.HIDDEN_01, NeuronName.HIDDEN_02, NeuronName.HIDDEN_03, NeuronName.HIDDEN_04, NeuronName.HIDDEN_05 };
        outputNeuronNames = new NeuronName[] { NeuronName.MOVE, NeuronName.ROTATE, NeuronName.ADJUST, NeuronName.LOOK, NeuronName.SHOOT };
    }
    
    // create the needed neurons
    for (NeuronName name : inputNeuronNames)
    {
      inputNeurons.put(name, new Neuron(Layer.INPUT, name));
    }
    // create the static input neuron
    inputNeurons.put(NeuronName.STATIC, new Neuron(Layer.INPUT, NeuronName.STATIC));
    
    for (NeuronName name : hiddenNeuronNames)
    {
      hiddenNeurons.put(name, new Neuron(Layer.HIDDEN, name));
    }
    for (NeuronName name : outputNeuronNames)
    {
      outputNeurons.put(name, new Neuron(Layer.OUTPUT, name));
    }
    
    // create the links between the neurons
    for (Neuron inputNeuron : inputNeurons.values())
    {
      for (Neuron hiddenNeuron : hiddenNeurons.values())
      {
        Link link = new Link(Link.DEFAULT_WEIGHT);
        inputNeuron.outputLinks.add(link);
        hiddenNeuron.inputLinks.add(link);
      }
    }
    for (Neuron hiddenNeuron : hiddenNeurons.values())
    {
      for (Neuron outputNeuron : outputNeurons.values())
      {
        Link link = new Link(Link.DEFAULT_WEIGHT);
        hiddenNeuron.outputLinks.add(link);
        outputNeuron.inputLinks.add(link);
      }
    }
  }
}

class Neuron
{
  final static float DEFAULT_THRESHOLD = .5f;
  
  NeuronName name;
  float threshold = DEFAULT_THRESHOLD;
  ArrayList<Link> inputLinks = new ArrayList();
  ArrayList<Link> outputLinks = new ArrayList();
  Layer layer;
  
  Neuron(Layer layer, NeuronName name)
  {
    this.layer = layer;
    this.name = name;
    Link link = new Link(Link.DEFAULT_WEIGHT);
    switch (layer)
    {
      case INPUT:
        inputLinks.add(link);
        if (name == NeuronName.STATIC)
          // the static neuron always produces an output of 0.5
          link.impulse = DEFAULT_THRESHOLD / Link.DEFAULT_WEIGHT + .5;
        break;
      case OUTPUT:
        outputLinks.add(link);
      default:
    }
  }
  
  public void resolve()
  {
    float impulses = -DEFAULT_THRESHOLD;
    for (Link link : inputLinks)
    {
      message ("input for " + name.name() + ": " + link.getImpulse());
      impulses += link.getImpulse();
    }
    
    // clip the solution at -1 and 1
    float solution = Math.max(-1, Math.min(1, impulses));
    for (Link link : outputLinks)
    {
      link.impulse = solution;
    }
    message ("solution for " + name.name() + ": " + solution);
  }
}

class Link
{
  final static float DEFAULT_WEIGHT = 1f;
  float weight;
  float impulse = 0;

  Link(float weight)
  {
    this.weight = weight;
  }
  
  public float getImpulse()
  {
    return weight * impulse;
  }
}

enum NetworkPrototype
{
  FLYING_ROBOT_STRATEGY
}
enum Layer
{
  INPUT, HIDDEN, OUTPUT
}
enum NeuronName
{
  HAPTIC, VISUAL_TYPE, VISUAL_POSITION, WEAPON, ENERGY, STATIC, HIDDEN_01, HIDDEN_02, HIDDEN_03, HIDDEN_04, HIDDEN_05, MOVE, ROTATE, ADJUST, LOOK, SHOOT
}
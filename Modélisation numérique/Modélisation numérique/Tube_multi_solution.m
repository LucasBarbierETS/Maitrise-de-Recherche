function launch_comsol_assembly(sol1, sol2)


import com.comsol.model.*
import com.comsol.model.util.*

model = ModelUtil.create('Model');

model.modelPath(['E:\OneDrive - ETS\CRIAQ-REAR\Maitrise LB\Mod' native2unicode(hex2dec({'00' 'e9'}), 'unicode') 'lisation num' native2unicode(hex2dec({'00' 'e9'}), 'unicode') 'rique']);

model.param.set('w1', '30e-3', 'largeur de la solution 1');
model.param.set('w2', '30e-3', 'largeur de la solution 2');
model.param.set('d12', '20e-3', 'distance inter-microphone');
model.param.set('d2s', '80e-3', 'distance microphone 2 - solution');
model.param.set('W', 'w1+w2+2e-3', 'largeur totale du tube');
model.param.set('c1', 'w1/2', 'ligne centrale de la solution 1')
model.param.set('c2', 'W-w2/2', 'ligne centrale de la solution 2')

comp1 = model.component.create('comp1', true);

geom1 = comp1.geom.create('geom1', 2);

r1 = geom1.create('r1', 'Rectangle');
r1.set('size', {'W' 'd12'});
r1.set('pos', {'0' 'd2s'})

r2 = geom1.create('r2', 'Rectangle');
r2.set('size', {'0' '0'});

pare1 = geom1.create('pare1', 'PartitionEdges');
pare1.selection('edge').set('r2', 1);
pare1.setIndex('param', 'w1/W', 0);
pare1.setIndex('param', '(W-w2)/W', 1);


% Construction des géométries des solutions 

model = sol1.set_COMSOL_model(model, x_centerline);

out = model;
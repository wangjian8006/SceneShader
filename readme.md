<h1>一套场景shader效果</h1>
<h2>AFT_Scene_Standard 场景标准Shader</h2>
算法：LightMap + HalfLambert漫反射 + BlinnPhong高光</br>
属性介绍：</br>
	主颜色</br>
	主贴图</br>
	法线贴图(没有法线贴图不会计算光照模型)</br>
	高光贴图（单通道）【如果可以的话将单通道高光放入到主贴图alpha中最合适，这样少一张贴图】</br>
	HalfLambert  计算漫反射</br>
	SpecularSharp 高光迭代次数</br>
	SpecularIntensity 高光强度</br>

<h2>AFT_Scene_PBR 场景PBRshader</h2>
算法：metallic workflow的PBR，带镜面反射</br>
属性介绍：</br>
	主颜色</br>
	主贴图</br>
	法线贴图(没有法线贴图不会计算光照模型)</br>
	高光贴图（r代表金属度，g代表粗糙度）</br>
	_Roughness (当这个值小于等于0的时候，会使用高光贴图的g代表粗糙度，否则使用这个值为粗糙度)</br>
	_GlossMapScale 控制平滑度</br>

	_RefectionTex 反射贴图</br>
	_RefectionColor	反射颜色</br>
特性：</br>
	在非运行环境下，需要加一盏平行光来计算高光与法线【实际游戏不需要】</br>
	在地穴环境下，为shader集成了点光源的特性，会照亮场景</br>

<h2>脚本</h2>
	在跑的时候加上一个SceneLightController组件放到主角身上。</br>
	GlobalAmbientColor		代表环境光</br>
	GlobalDirectionLightDir 	代表主光源方向【这个用于运行环境下模拟平行光】</br>
	GlobalDirectionLightColor	代表主光源颜色【这个用于运行环境下模拟平行光】</br>
	bOpenPointLight			是否开启点光源，策划配置，当在地穴的环境下会开启点光源，照亮场景</br>
	GlobalPointLightRange		点光源范围</br>
	GlobalPointLightColor		点光源的颜色</br>
	GlobalPointLightIntensity	点光源强度</br>
	GlobalPointLightSpecularSharp	点光源的高光</br>
	GlobalPointLightPositionYOffset	点光源的高度偏移值</br>